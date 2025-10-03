defmodule AppWeb.Plugs.RequireRole do
  import Plug.Conn
  alias Phoenix.Controller

  def init(opts), do: opts

  # roles argument is list like ["superuser"] or ["admin","superuser"]
  def call(conn, roles) when is_list(roles) do
    user = conn.assigns[:current_user]
    if user && user.user_type in roles do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> Controller.json(%{message: "Forbidden: insufficient privileges"})
      |> halt()
    end
  end
end
