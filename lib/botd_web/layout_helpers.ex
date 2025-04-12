defmodule BotdWeb.LayoutHelpers do
  use Phoenix.Component
  import Phoenix.Controller, only: [get_csrf_token: 0]
  alias Pow.Plug

  def current_user(assigns) do
    user = Plug.current_user(assigns.conn)
    assign(assigns, :current_user, user)
  end
end
