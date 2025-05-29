defmodule Botd.People.Photo do
  @moduledoc """
  The Photo schema and changeset functions.
  Photos represent the images associated with persons in the Book of the Dead (BOTD) application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  # @sizes [
  #   :tiny,
  #   :small,
  #   :medium,
  #   :large
  # ]

  schema "photos" do
    field :url, :string
    field :size, :string
    belongs_to :person, Botd.People.Person

    timestamps()
  end

  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:url, :person_id, :size])
    |> validate_required([:url, :person_id])

    # |> validate_inclusion(:size, @sizes)
  end
end
