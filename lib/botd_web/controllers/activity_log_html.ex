defmodule BotdWeb.ActivityLogHTML do
  use BotdWeb, :html
  import BotdWeb.PaginationComponent

  embed_templates "activity_log_html/*"

  def action_color(action) do
    case action do
      :create -> "text-green-600"
      :edit -> "text-blue-600"
      :remove -> "text-red-600"
      _ -> ""
    end
  end

  def format_action(action) do
    action |> to_string() |> String.capitalize()
  end

  def format_timestamp(timestamp) do
    Calendar.strftime(timestamp, "%Y-%m-%d %H:%M:%S")
  end
end
