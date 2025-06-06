defmodule Botd.People.Person do
  @moduledoc """
  The Person schema and changeset functions.

  This module defines the Person schema with attributes. It also provides
  changeset functions for validating and preparing data for database operations.

  Persons represent the core data entities in the Book of the Dead (BOTD) application.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :name, :string
    field :nickname, :string
    field :birth_date, :date
    field :death_date, :date
    field :place, :string
    field :cause_of_death, :string
    field :description, :string
    field :photo_url, :string
    has_many :photos, Botd.People.Photo

    timestamps()
  end

  def changeset(person, attrs) do
    person
    |> cast(attrs, [
      :name,
      :nickname,
      :birth_date,
      :death_date,
      :place,
      :cause_of_death,
      :description,
      :photo_url
    ])
    |> validate_required([:name, :death_date])
    |> validate_death_date_not_in_future()
    |> unique_constraint([:name, :death_date],
      name: :people_name_death_date_index,
      message: "A person with this name and death date already exists"
    )
  end

  defp validate_death_date_not_in_future(changeset) do
    validate_change(changeset, :death_date, fn :death_date, death_date ->
      if Date.compare(death_date, Date.utc_today()) == :gt do
        [death_date: "cannot be in the future"]
      else
        []
      end
    end)
  end
end
