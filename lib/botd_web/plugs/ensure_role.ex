defmodule BotdWeb.Plugs.EnsureRole do
  @moduledoc """
  This plug ensures that a user has a specific role before accessing a route.
  """
  alias Botd.Accounts.User
  use BotdWeb, :controller
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, opts) do
    required_roles = Keyword.fetch!(opts, :roles)

    case conn.assigns[:current_user] do
      # credo:disable-for-next-line Credo.Check.Design.TagTODO
      # TODO: Samu - how to make a guard clause for roles? here?
      # How I can do something like this `%User{role: role} when role in roles ->`?
      %User{role: role} ->
        if role in required_roles do
          conn
        else
          deny_access(conn)
        end

      _ ->
        deny_access(conn)
    end
  end

  defp deny_access(conn) do
    conn
    |> put_flash(:error, "You are not authorized to access this page.")
    |> redirect(to: ~p"/")
    |> halt()
  end
end
