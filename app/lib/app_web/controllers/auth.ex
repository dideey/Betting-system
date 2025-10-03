defmodule AppWeb.AuthController do
  use AppWeb, :controller
  alias App.AccountsContext
  alias App.Sports.User

  # Handle registration with nested "user" parameters
  def register(conn, %{"user" => user_params}) do
    case AccountsContext.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{
          status: "success",
          message: "User registered successfully",
          data: %{
            id: user.id,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            user_type: user.user_type
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          status: "error",
          message: "Registration failed",
          errors: format_changeset_errors(changeset)
        })
    end
  end

  # Handle registration when parameters are not nested under "user"
  def register(conn, user_params) when is_map(user_params) do
    register(conn, %{"user" => user_params})
  end

  # Handle login with nested "user" parameters
  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case AccountsContext.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> json(%{
          status: "success",
          message: "Login successful",
          data: %{
            id: user.id,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            user_type: user.user_type
          }
        })

      {:error, :account_inactive} ->
        conn
        |> put_status(:forbidden)  # 403 status for inactive accounts
        |> json(%{
          status: "error",
          message: "Account is inactive. Please contact support."
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          status: "error",
          message: "Invalid email or password"
        })
    end
  end

  # Handle login with direct email/password parameters
  def login(conn, %{"email" => email, "password" => password}) do
  case AccountsContext.authenticate_user(email, password) do
    {:ok, user} ->
      conn
      |> put_session(:user_id, user.id)
      |> json(%{
        status: "success",
        message: "Login successful",
        data: %{
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          user_type: user.user_type
        }
      })

    {:error, :account_inactive} ->
      conn
      |> put_status(:forbidden)
      |> json(%{
        status: "error",
        message: "Account deactivated"
      })

    {:error, :invalid_credentials} ->
      conn
      |> put_status(:unauthorized)
      |> json(%{
        status: "error",
        message: "Invalid email or password"
      })
  end
end


  def logout(conn, _params) do
    conn
    |> clear_session()
    |> json(%{
      status: "success",
      message: "Logged out successfully"
    })
  end

  # Helper function to format changeset errors
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
