defmodule BotdWeb.Plugs.EnsureRole do
  @moduledoc """
  This plug ensures that a user has a specific role before accessing a route.
  """
  import Plug.Conn
  import Phoenix.Controller
  alias Botd.Users.User

  def init(options), do: options

  def call(conn, roles) do
    user = Pow.Plug.current_user(conn)

    if User.has_role?(user, roles) do
      conn
    else
      conn
      |> put_flash(:error, "You don't have permission to access this page")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
