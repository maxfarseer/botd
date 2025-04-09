# schema
defmodule Botd.People.Person do
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
      :description
    ])
    |> validate_required([:name, :death_date])
    |> unique_constraint([:name, :death_date],
      name: :people_name_death_date_index,
      message: "A person with this name and death date already exists"
    )
  end
end
