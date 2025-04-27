defmodule BotdWeb.ActivityLogController do
  use BotdWeb, :controller
  alias Botd.ActivityLogs

  def index(conn, params) do
    page = params["page"] || "1"
    per_page = params["per_page"] || "10"

    {page, _} = Integer.parse(page)
    {per_page, _} = Integer.parse(per_page)

    %{entries: activity_logs, page_number: page_number, total_pages: total_pages} =
      ActivityLogs.list_activity_logs(page: page, per_page: per_page)

    render(conn, :index,
      activity_logs: activity_logs,
      page_number: page_number,
      total_pages: total_pages,
      per_page: per_page
    )
  end

  def index_test(conn, params) do
    page = params["page"] || "1"
    per_page = params["per_page"] || "10"

    {page, _} = Integer.parse(page)
    {per_page, _} = Integer.parse(per_page)

    %{entries: activity_logs, page_number: page_number, total_pages: total_pages} =
      ActivityLogs.list_activity_logs2(page: page, per_page: per_page)

    render(conn, :index_test,
      activity_logs: activity_logs,
      page_number: page_number,
      total_pages: total_pages,
      per_page: per_page
    )
  end
end
