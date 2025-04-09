defmodule BotdWeb.PersonController do
  use BotdWeb, :controller
  alias Botd.People
  alias Botd.People.Person

  def index(conn, _params) do
    people = People.list_people()
    render(conn, :index, people: people)
  end

  def new(conn, _params) do
    changeset = People.change_person(%Person{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"person" => person_params}) do
    case People.create_person(person_params) do
      {:ok, person} ->
        conn
        |> put_flash(:info, "Person created successfully.")
        |> redirect(to: ~p"/people/#{person}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    person = People.get_person!(id)
    render(conn, :show, person: person)
  end
end
