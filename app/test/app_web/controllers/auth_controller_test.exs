defmodule AppWeb.AuthControllerTest do
  use AppWeb.ConnCase, async: true

  alias App.AccountsContext
  alias App.Accounts.User
  alias App.Repo

  @valid_user %{
    "first_name" => "John",
    "last_name" => "Doe",
    "email" => "john@example.com",
    "msisdn" => "0712345678",
    "password" => "secret123"
  }

  # --------------------------
  # REGISTER TESTS
  # --------------------------
  describe "POST /api/auth/register" do
    test "registers a new user successfully", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", @valid_user)
      response = json_response(conn, 201)

      assert response["message"] == "User registered successfully"
      assert response["data"]["email"] == "john@example.com"

      user = Repo.get_by(User, email: "john@example.com")
      assert user
    end

    test "fails registration with missing fields", %{conn: conn} do
      invalid = Map.drop(@valid_user, ["email"])
      conn = post(conn, ~p"/api/auth/register", invalid)
      response = json_response(conn, 422)

      assert response["message"] == "Registration failed"
    end

    test "fails registration with duplicate email", %{conn: conn} do
      # First registration
      {:ok, _user} = AccountsContext.register_user(@valid_user)
      # Second attempt with same email
      conn = post(conn, ~p"/api/auth/register", @valid_user)
      response = json_response(conn, 422)

      assert response["message"] == "Registration failed"
    end
  end

  # --------------------------
  # LOGIN TESTS
  # --------------------------
  describe "POST /api/auth/login" do
    setup do
      {:ok, user} = AccountsContext.register_user(@valid_user)
      %{user: user}
    end

    test "logs in with correct credentials", %{conn: conn, user: user} do
      params = %{"email" => user.email, "password" => "secret123"}
      conn = post(conn, ~p"/api/auth/login", params)
      response = json_response(conn, 200)

      assert response["message"] == "Login successful"
      assert response["data"]["id"] == user.id
      assert get_session(conn, :user_id) == user.id
    end

    test "rejects wrong password", %{conn: conn, user: user} do
      params = %{"email" => user.email, "password" => "wrongpass"}
      conn = post(conn, ~p"/api/auth/login", params)
      response = json_response(conn, 401)

      assert response["message"] == "Invalid email or password"
    end

    test "rejects non-existent user", %{conn: conn} do
      params = %{"email" => "ghost@example.com", "password" => "anything"}
      conn = post(conn, ~p"/api/auth/login", params)
      response = json_response(conn, 401)

      assert response["message"] == "Invalid email or password"
    end

    test "rejects inactive user", %{conn: conn, user: user} do
      user |> Ecto.Changeset.change(is_active: false) |> Repo.update!()
      params = %{"email" => user.email, "password" => "secret123"}
      conn = post(conn, ~p"/api/auth/login", params)
      response = json_response(conn, 403)

      assert response["message"] == "Account deactivated"
    end
  end

  # --------------------------
  # LOGOUT TESTS
  # --------------------------
  describe "POST /api/auth/logout" do
    setup do
      {:ok, user} = AccountsContext.register_user(@valid_user)
      %{user: user}
    end

    test "logs out and clears session", %{conn: conn, user: user} do
      conn = conn |> init_test_session(%{}) |> put_session(:user_id, user.id)
      assert get_session(conn, :user_id) == user.id

      conn = post(conn, ~p"/api/auth/logout")
      response = json_response(conn, 200)

      assert response["message"] == "Logged out successfully"
      refute get_session(conn, :user_id)
    end

    test "logout works even if no user is logged in", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/logout")
      response = json_response(conn, 200)

      assert response["message"] == "Logged out successfully"
    end
  end
end
