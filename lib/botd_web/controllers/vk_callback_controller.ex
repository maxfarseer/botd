defmodule BotdWeb.VKCallbackController do
  @moduledoc """
  Handles incoming VK community Callback API requests.

  VK requires:
  1. A confirmation handshake: respond with the confirmation string from VK community settings
  2. Respond with "ok" (plain text) for every other event within 10 seconds

  Configuration via env vars:
  - VK_CONFIRMATION_STRING — string shown in VK community Callback API settings
  - VK_SECRET_KEY — optional secret for verifying requests (set in VK settings)
  """

  use BotdWeb, :controller

  require Logger

  def handle(conn, %{"type" => "confirmation"} = _params) do
    confirmation_string = System.get_env("VK_CONFIRMATION_STRING", "")
    text(conn, confirmation_string)
  end

  def handle(conn, params) do
    if valid_secret?(params) do
      Task.start(fn -> Botd.VK.process_event(params) end)
    else
      Logger.warning("VK callback: invalid secret key, ignoring event")
    end

    text(conn, "ok")
  end

  defp valid_secret?(params) do
    secret = System.get_env("VK_SECRET_KEY")

    case secret do
      nil -> true
      "" -> true
      expected -> params["secret"] == expected
    end
  end
end
