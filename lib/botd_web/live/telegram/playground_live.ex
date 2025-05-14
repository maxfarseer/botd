defmodule BotdWeb.Telegram.PlaygroundLive do
  @moduledoc """
  This controller is used to handle Telegram bot interactions.

  The answer message is:
  Message: %{
    "chat" => %{
      "first_name" => "Max",
      "id" => 123456789,
      "last_name" => "P",
      "type" => "private",
      "username" => "test_username"
    },
    "date" => 1746525897,
    "from" => %{
      "first_name" => "Max",
      "id" => 123456789,
      "is_bot" => false,
      "is_premium" => true,
      "language_code" => "en",
      "last_name" => "P",
      "username" => "usetest_username"
    },
    "message_id" => 5,
    "text" => "About something..."
  }
  """
  use BotdWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Botd.PubSub, "telegram_bot_update")
    {:ok, assign(socket, messages: [])}
  end

  @impl true
  def handle_info({:update, update}, socket) do
    {:noreply, assign(socket, messages: [to_message(update) | socket.assigns.messages])}
  end

  defp to_message(%{"message" => message} = _update) do
    firstname = get_in(message, ["from", "first_name"])
    lastname = get_in(message, ["from", "last_name"])
    username = get_in(message, ["from", "username"])

    from =
      case {firstname, lastname, username} do
        {nil, _, username} -> username
        {firstname, nil, _} -> firstname
        {firstname, lastname, _} -> "#{firstname} #{lastname}"
      end

    text = get_in(message, ["text"])
    %{from: from, text: text}
  end
end
