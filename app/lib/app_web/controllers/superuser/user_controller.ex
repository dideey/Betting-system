defmodule AppWeb.Superuser.UserController do
  use AppWeb, :controller
  alias App.AccountsContext
  alias App.Accounts.User

  # POST /api/superuser/users/:id/role
  def set_role(conn, %{"id" => id, "user_type" => user_type}) do
    case AccountsContext.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "User not found"})

      user ->
        case AccountsContext.update_user_role(user, %{"user_type" => user_type}) do
          {:ok, updated_user} ->
            json(conn, %{
              status: "success",
              message: "User role updated",
              data: %{id: updated_user.id, user_type: updated_user.user_type}
            })

          {:error, changeset} ->
            errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
              Enum.reduce(opts, msg, fn {key, value}, acc ->
                String.replace(acc, "%{#{key}}", to_string(value))
              end)
            end)

            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", message: "Invalid data", errors: errors})
        end
    end
  end

  # DELETE /api/superuser/users/:id
  def soft_delete(conn, %{"id" => id}) do
    case AccountsContext.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "User not found"})

      user ->
        {:ok, _} = AccountsContext.soft_delete_user(user)
        json(conn, %{status: "success", message: "User soft-deleted"})
    end
  end

  # GET /api/superuser/users/:id
  def show(conn, %{"id" => id}) do
    case AccountsContext.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "User not found"})

      user ->
        json(conn, %{
          status: "success",
          data: %{
            id: user.id,
            email: user.email,
            user_type: user.user_type,
            is_active: user.is_active
          }
        })
    end
  end
end
