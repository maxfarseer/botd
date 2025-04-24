defmodule BotdWeb.PersonHTML do
  use BotdWeb, :html

  import BotdWeb.Helpers
  import BotdWeb.PaginationComponent

  embed_templates "person_html/*"

  @doc """
  Renders a person form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def person_form(assigns) do
    ~H"""
    <.simple_form :let={f} for={@changeset} action={@action}>
      <.error :if={@changeset.action}>
        Oops, something went wrong! Please check the errors below.
      </.error>

      <.input field={f[:name]} type="text" label="Name" required />
      <.input field={f[:nickname]} type="text" label="Nickname" />
      <.input field={f[:birth_date]} type="date" label="Birth date" />
      <.input field={f[:death_date]} type="date" label="Death date" required />
      <.input field={f[:place]} type="text" label="Place" />
      <.input field={f[:cause_of_death]} type="textarea" label="Cause of death" />
      <.input field={f[:description]} type="textarea" label="Description" />

      <:actions>
        <.button>Save Person</.button>
      </:actions>
    </.simple_form>
    """
  end
end
