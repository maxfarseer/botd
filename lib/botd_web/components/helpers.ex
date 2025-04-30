defmodule BotdWeb.Helpers do
  @moduledoc """
  View helpers for role-based access control.
  """

  def admin?(_conn) do
    false
  end

  def moderator_or_admin?(_conn) do
    false
  end

  def show_if(condition, content) do
    if condition, do: content, else: ""
  end
end
