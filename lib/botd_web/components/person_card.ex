defmodule BotdWeb.PersonCard do
  @moduledoc """
  This module defines a component for displaying a person's information in a card format.
  """
  use Phoenix.Component
  import BotdWeb.CoreComponents

  attr :person, :map, required: true

  def person_card(assigns) do
    ~H"""
    <div class="flex items-center bg-gray-100 rounded-lg shadow-md p-4 mb-4 mr-4">
      <%= if @person.photo_url do %>
        <img
          src={@person.photo_url}
          alt={@person.name}
          class="w-20 h-20 object-cover rounded-full border mr-6"
        />
      <% else %>
        <.icon name="hero-camera" class="w-20 h-20 text-gray-300 mr-6" />
      <% end %>
      <div class="flex-1">
        <div class="text-xl">{@person.name}</div>
        <div class="text-gray-500 text-sm mb-2">
          <%= if @person.death_date do %>
            ✝ {@person.death_date}
          <% end %>
        </div>
        <.link href={"/people/#{@person.id}"} class="text-blue-600 hover:underline">
          Read more
        </.link>
      </div>
    </div>
    """
  end
end
