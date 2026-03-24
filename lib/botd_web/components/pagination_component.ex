defmodule BotdWeb.PaginationComponent do
  @moduledoc """
  Renders a pagination component with "Previous" and "Next" links styled with TailwindCSS.

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
    <div class="flex items-center justify-between border-t border-outline-variant bg-surface-container px-4 py-3 sm:px-6">
      <div class="flex flex-1 justify-between sm:hidden">
        <%= if @page_number > 1 do %>
          <.link
            href={"#{@path}?page=#{@page_number - 1}&per_page=#{@per_page}"}
            class="relative inline-flex items-center border border-outline-variant bg-surface-container px-4 py-2 text-sm font-medium text-on-surface hover:bg-surface-container-high"
          >
            Previous
          </.link>
        <% else %>
          <span class="relative inline-flex items-center border border-outline-variant bg-surface-container-high px-4 py-2 text-sm font-medium text-on-surface-variant cursor-not-allowed">
            Previous
          </span>
        <% end %>
        <%= if @page_number < @total_pages do %>
          <.link
            href={"#{@path}?page=#{@page_number + 1}&per_page=#{@per_page}"}
            class="relative ml-3 inline-flex items-center border border-outline-variant bg-surface-container px-4 py-2 text-sm font-medium text-on-surface hover:bg-surface-container-high"
          >
            Next
          </.link>
        <% else %>
          <span class="relative ml-3 inline-flex items-center border border-outline-variant bg-surface-container-high px-4 py-2 text-sm font-medium text-on-surface-variant cursor-not-allowed">
            Next
          </span>
        <% end %>
      </div>
      <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
        <div>
          <p class="text-sm text-on-surface-variant">
            Showing page <span class="font-medium">{@page_number}</span>
            of <span class="font-medium">{@total_pages}</span>
          </p>
        </div>
        <div>
          <nav class="isolate inline-flex -space-x-px" aria-label="Pagination">
            <%= if @page_number > 1 do %>
              <.link
                href={"#{@path}?page=#{@page_number - 1}&per_page=#{@per_page}"}
                class="relative inline-flex items-center px-2 py-2 text-outline ring-1 ring-inset ring-outline-variant hover:bg-surface-container-high focus:z-20 focus:outline-offset-0"
              >
                <span class="sr-only">Previous</span>
                <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path
                    fill-rule="evenodd"
                    d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z"
                    clip-rule="evenodd"
                  />
                </svg>
              </.link>
            <% else %>
              <span class="relative inline-flex items-center px-2 py-2 text-outline-variant ring-1 ring-inset ring-outline-variant cursor-not-allowed">
                <span class="sr-only">Previous</span>
                <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path
                    fill-rule="evenodd"
                    d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z"
                    clip-rule="evenodd"
                  />
                </svg>
              </span>
            <% end %>

            <span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-on-surface ring-1 ring-inset ring-outline-variant focus:outline-offset-0">
              {@page_number} / {@total_pages}
            </span>

            <%= if @page_number < @total_pages do %>
              <.link
                href={"#{@path}?page=#{@page_number + 1}&per_page=#{@per_page}"}
                class="relative inline-flex items-center px-2 py-2 text-outline ring-1 ring-inset ring-outline-variant hover:bg-surface-container-high focus:z-20 focus:outline-offset-0"
              >
                <span class="sr-only">Next</span>
                <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path
                    fill-rule="evenodd"
                    d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                    clip-rule="evenodd"
                  />
                </svg>
              </.link>
            <% else %>
              <span class="relative inline-flex items-center px-2 py-2 text-outline-variant ring-1 ring-inset ring-outline-variant cursor-not-allowed">
                <span class="sr-only">Next</span>
                <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path
                    fill-rule="evenodd"
                    d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                    clip-rule="evenodd"
                  />
                </svg>
              </span>
            <% end %>
          </nav>
        </div>
      </div>
    </div>
    """
  end
end
