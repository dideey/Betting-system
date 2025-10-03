defmodule AppWeb.Plugs.LoadCurrentUser do
  import Plug.Conn
  alias App.AccountsContext

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = if user_id, do: AccountsContext.get_user(user_id), else: nil
    assign(conn, :current_user, user)
  end
end
