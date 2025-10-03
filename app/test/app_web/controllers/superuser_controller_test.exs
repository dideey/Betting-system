defmodule AppWeb.SuperuserControllerTest do
  use AppWeb.ConnCase
  alias App.AccountsContext
  alias App.Repo
  alias App.Accounts.User
  alias App.Sports.Game

  import Ecto.Query

  setup do
    superuser =
      %User{
        email: "admin@example.com",
        password_hash: Bcrypt.hash_pwd_salt("password"),
        user_type: "superuser",
        is_active: true
      }
      |> Repo.insert!()

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> init_test_session(user_id: superuser.id)
      |> assign(:current_user, superuser)

    {:ok, conn: conn, superuser: superuser}
  end

  # -------------------
  # Game Management
  # -------------------
  describe "Games API" do
    test "creates a game", %{conn: conn} do
      params = %{
        "game_type" => "football",
        "team_a" => "Team Alpha",
        "team_b" => "Team Beta",
        "odds_a" => 1.5,
        "odds_b" => 2.5,
        "start_time" => "2025-10-03T15:00:00Z"
      }

      conn = post(conn, "/api/superuser/games", %{"game" => params})
      response = json_response(conn, 201)

      assert response["status"] == "success"
      assert response["data"]["team_a"] == "Team Alpha"
    end

    test "fails to create a game with missing params", %{conn: conn} do
      conn = post(conn, "/api/superuser/games", %{})
      response = json_response(conn, 422)

      assert response["status"] == "error"
      assert response["message"] == "Missing game params"

    end

    test "lists all games", %{conn: conn} do
      conn = get(conn, "/api/superuser/games")
      response = json_response(conn, 200)

      assert is_list(response["data"])
    end

    test "updates a game", %{conn: conn} do
      game = Repo.insert!(%Game{
        game_type: "basketball",
        team_a: "A",
        team_b: "B",
        odds_a: 1.2,
        odds_b: 1.8,
        start_time: ~U[2025-10-03 12:00:00Z]
      })

      update_params = %{
        "team_a" => "Updated A",
        "game_type" => "basketball",
        "odds_a" => 1.4
      }

      conn = put(conn, "/api/superuser/games/#{game.id}", %{"game" => update_params})
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["data"]["team_a"] == "Updated A"
      assert response["data"]["odds_a"] == 1.4
    end

    test "fails to update non-existent game", %{conn: conn} do
      conn = put(conn, "/api/superuser/games/99999", %{"game" => %{"team_a" => "X"}})
      response = json_response(conn, 404)

      assert response["status"] == "error"
    end

    test "deletes a game", %{conn: conn} do
      game = Repo.insert!(%Game{
        team_a: "A",
        team_b: "B",
        odds_a: 1.2,
        odds_b: 1.8,
        start_time: ~U[2025-10-03 12:00:00Z]
      })

      conn = delete(conn, "/api/superuser/games/#{game.id}")
      response = json_response(conn, 200)

      assert response["status"] == "success"
    end

    test "fails to delete non-existent game", %{conn: conn} do
      conn = delete(conn, "/api/superuser/games/99999")
      response = json_response(conn, 404)

      assert response["status"] == "error"
    end

    test "resolves a game", %{conn: conn} do
      game = Repo.insert!(%Game{
        team_a: "A",
        team_b: "B",
        odds_a: 1.2,
        odds_b: 1.8,
        start_time: ~U[2025-10-03 12:00:00Z]
      })

      params = %{"result" => "A"}

      conn = post(conn, "/api/superuser/games/#{game.id}/resolve", params)
      response = json_response(conn, 200)

      assert response["status"] == "success"
    end

    test "fails to resolve non-existent game", %{conn: conn} do
      conn = post(conn, "/api/superuser/games/99999/resolve", %{"result" => "A"})
      response = json_response(conn, 404)

      assert response["status"] == "error"
    end
  end

  # -------------------
  # User Management
  # -------------------
  describe "Users API" do
    setup do
      user =
        %User{
          email: "user@example.com",
          password_hash: Bcrypt.hash_pwd_salt("password"),
          is_active: true,
          user_type: "user"
        }
        |> Repo.insert!()

      normal_user =
        %User{
          email: "normal@example.com",
          password_hash: Bcrypt.hash_pwd_salt("password"),
          is_active: true,
          user_type: "user"
        }
        |> Repo.insert!()

      {:ok, user: user, normal_user: normal_user}
    end

    test "sets a user role", %{conn: conn, user: user} do
      params = %{"user_type" => "admin"}

      conn = post(conn, "/api/superuser/users/#{user.id}/role", params)
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["data"]["user_type"] == "admin"
    end

    test "fails to set role for non-existent user", %{conn: conn} do
      conn = post(conn, "/api/superuser/users/99999/role", %{"user_type" => "admin"})
      response = json_response(conn, 404)

      assert response["status"] == "error"
    end

    test "soft deletes a user", %{conn: conn, user: user} do
      conn = delete(conn, "/api/superuser/users/#{user.id}")
      response = json_response(conn, 200)

      assert response["status"] == "success"
    end

    test "fails to soft delete non-existent user", %{conn: conn} do
      conn = delete(conn, "/api/superuser/users/99999")
      response = json_response(conn, 404)

      assert response["status"] == "error"
    end

    test "shows a user", %{conn: conn, user: user} do
      conn = get(conn, "/api/superuser/users/#{user.id}")
      response = json_response(conn, 200)

      assert response["status"] == "success"
      assert response["data"]["email"] == "user@example.com"
    end

    test "fails to show non-existent user", %{conn: conn} do
      conn = get(conn, "/api/superuser/users/99999")
      response = json_response(conn, 404)

      assert response["status"] == "error"
    end

    test "normal user cannot access superuser routes", %{normal_user: normal_user} do
      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> assign(:current_user, normal_user)

      conn = get(conn, "/api/superuser/games")
      assert response(conn, 403)
    end
  end
end
