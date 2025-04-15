defmodule BotdWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use BotdWeb, :html

  import BotdWeb.Helpers

  embed_templates "page_html/*"
end
