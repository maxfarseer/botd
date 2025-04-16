defmodule BotdWeb.SuggestionHTML do
  @moduledoc """
  This module contains pages rendered by SuggestionController.

  See the `suggestion_html` directory for all templates available.
  """
  use BotdWeb, :html

  embed_templates "suggestion_html/*"
end
