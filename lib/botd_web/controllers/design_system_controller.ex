defmodule BotdWeb.DesignSystemController do
  use BotdWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
