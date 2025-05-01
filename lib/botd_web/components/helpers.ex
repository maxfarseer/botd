defmodule BotdWeb.Helpers do
  @moduledoc """
  View helpers for role-based access control.
  """

  alias Botd.Accounts.User

  def admin?(conn) do
    case conn.assigns[:current_user] do
      %User{role: :admin} -> true
      _ -> false
    end
  end

  def moderator_or_admin?(conn) do
    case conn.assigns[:current_user] do
      %User{role: role} when role in [:moderator, :admin] -> true
      _ -> false
    end
  end

  def show_if(condition, content) do
    if condition, do: content, else: ""
  end
end
