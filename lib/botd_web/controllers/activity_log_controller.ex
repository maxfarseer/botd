defmodule BotdWeb.ActivityLogController do
  use BotdWeb, :controller
  alias Botd.ActivityLogs

  def index(conn, _params) do
    activity_logs = ActivityLogs.list_activity_logs()
    render(conn, :index, activity_logs: activity_logs)
  end
end
