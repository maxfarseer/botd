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
  alias Botd.People.Photo
  alias Botd.Repo

  def list_people(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    Person
    |> order_by(desc: :updated_at)
    |> Repo.paginate(page: page, page_size: per_page)
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

  def create_photo(attrs) do
    %Photo{}
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end
end
