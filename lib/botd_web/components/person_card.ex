defmodule BotdWeb.PersonCard do
  @moduledoc """
  This module defines a component for displaying a person's information in a card format.
  """
  use Phoenix.Component
  import BotdWeb.CoreComponents

  attr :person, :map, required: true

  def person_card(assigns) do
    ~H"""
    <.link href={"/people/#{@person.id}"}>
      <div class="flex items-center m-4">
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
          <div class="text-xl mb-1">{@person.name}</div>
          <div class="text-gray-500 text-xs mb-1 font-light">
            {@person.birth_date} - {@person.death_date}
          </div>
          <div class="text-gray-500 text-xs mb-2">
            Несколько слов из description. Полный текст можно прочитать на странице человека. Здесь три строчки текста.
          </div>
        </div>
      </div>
    </.link>
    """
  end
end
