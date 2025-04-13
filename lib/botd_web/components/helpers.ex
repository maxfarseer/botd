defmodule BotdWeb.Helpers do
  @moduledoc """
  View helpers for role-based access control.
  """
  alias Botd.Users.User

  def admin?(conn) do
    conn
    |> Pow.Plug.current_user()
    |> User.admin?()
  end

  def moderator_or_admin?(conn) do
    conn
    |> Pow.Plug.current_user()
    |> User.moderator_or_admin?()
  end

  def show_if(condition, content) do
    if condition, do: content, else: ""
  end
end
