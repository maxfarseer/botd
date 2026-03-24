defmodule BotdWeb.DesignSystemHTML do
  use BotdWeb, :html

  import BotdWeb.PaginationComponent
  import BotdWeb.PersonCard

  embed_templates "design_system_html/*"
end
