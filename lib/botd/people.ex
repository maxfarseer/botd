defmodule Botd.People do
  @moduledoc """
  The People context.

  This context handles all database operations related to people (aka `Persons`) records,
  providing functions for CRUD operations (Create, Read, Update, Delete)
  and other business logic related to managing people data.

  Example:

      # List all people
      people = Botd.People.list_people()

      # Get a specific person
      person = Botd.People.get_person!(123)
  """
  import Ecto.Query, warn: false
  alias Botd.People.Person
  alias Botd.Repo

  def list_people do
    Repo.all(Person)
  end

  def get_person!(id), do: Repo.get!(Person, id)

  def create_person(attrs \\ %{}) do
    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert()
  end

  def update_person(%Person{} = person, attrs) do
    person
    |> Person.changeset(attrs)
    |> Repo.update()
  end

  def delete_person(%Person{} = person) do
    Repo.delete(person)
  end

  def change_person(%Person{} = person, attrs \\ %{}) do
    Person.changeset(person, attrs)
  end
end
