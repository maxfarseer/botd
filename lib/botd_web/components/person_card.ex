defmodule BotdWeb.PersonCard do
  @moduledoc """
  This module defines a component for displaying a person's information in a card format.
  """
  use Phoenix.Component
  import BotdWeb.CoreComponents

  attr :person, :map, required: true

  def person_card(assigns) do
    ~H"""
    <.link href={"/people/#{@person.id}"} class="block">
      <article class="group relative bg-surface-container-low p-6 transition-all duration-300 hover:-translate-y-1 hover:bg-surface-container">
        <div class="absolute inset-0 dither-pattern opacity-10 pointer-events-none"></div>
        <div class="relative flex flex-col h-full">
          <div class="flex items-start gap-4 mb-6">
            <div class="w-20 h-20 bg-surface-container-highest flex-shrink-0 card-inset overflow-hidden flex items-center justify-center border-2 border-outline-variant/30">
              <%= if @person.photo_url do %>
                <img
                  src={@person.photo_url}
                  alt={@person.name}
                  class="w-full h-full object-cover grayscale contrast-125 mix-blend-screen opacity-70"
                />
              <% else %>
                <.icon name="hero-camera" class="w-10 h-10 text-outline" />
              <% end %>
            </div>
            <div class="flex-grow">
              <h3 class="font-headline font-bold text-2xl text-on-surface leading-tight mb-1 group-hover:text-primary transition-colors uppercase">
                {@person.name}
              </h3>
              <p class="font-label text-secondary text-sm tracking-widest">
                {@person.birth_date} — {@person.death_date}
              </p>
            </div>
          </div>
          <div class="space-y-4">
            <%= if @person.description do %>
              <p class="text-on-surface-variant leading-relaxed text-sm line-clamp-3">
                {@person.description}
              </p>
            <% end %>
            <%= if @person.place do %>
              <div class="pt-4 border-t border-outline-variant/30 flex justify-between items-center">
                <span class="inline-block px-3 py-1 bg-primary-container text-primary text-[10px] font-label uppercase tracking-widest">
                  {@person.place}
                </span>
                <.icon
                  name="hero-archive-box"
                  class="w-5 h-5 text-outline group-hover:text-primary transition-colors"
                />
              </div>
            <% end %>
          </div>
        </div>
        <div class="absolute -bottom-1 -right-1 w-4 h-4 bg-primary opacity-0 group-hover:opacity-100 transition-opacity">
        </div>
      </article>
    </.link>
    """
  end
end
