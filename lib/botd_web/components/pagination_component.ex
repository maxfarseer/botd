defmodule BotdWeb.PaginationComponent do
  @moduledoc """
  Renders a pagination component with "Previous" and "Next" links.

  ## Examples

      <.pagination
        page_number={1}
        total_pages={5}
        per_page={10}
        path="/people"
      />

  ## Attributes

  * `page_number` - The current page number (integer)
  * `total_pages` - The total number of pages available (integer)
  * `per_page` - Number of items displayed per page (integer)
  * `path` - The base path for pagination links (string)
  """
  use Phoenix.Component

  attr :page_number, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :per_page, :integer, required: true
  attr :path, :string, required: true

  def pagination(assigns) do
    ~H"""
    <div class="pagination">
      <%= if @page_number > 1 do %>
        <.link href={"#{@path}?page=#{@page_number - 1}&per_page=#{@per_page}"}>
          Previous
        </.link>
      <% end %>

      <span>Page {@page_number} of {@total_pages}</span>

      <%= if @page_number < @total_pages do %>
        <.link href={"#{@path}?page=#{@page_number + 1}&per_page=#{@per_page}"}>
          Next
        </.link>
      <% end %>
    </div>
    """
  end
end
