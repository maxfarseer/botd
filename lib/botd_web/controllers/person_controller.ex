defmodule BotdWeb.PersonController do
  use BotdWeb, :controller
  alias Botd.ActivityLogs
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
        user = conn.assigns[:current_user]
        ActivityLogs.log_person_action(:create, person, user)

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

  def edit(conn, %{"id" => id}) do
    person = People.get_person!(id)
    changeset = People.change_person(person)
    render(conn, :edit, person: person, changeset: changeset)
  end

  def update(conn, %{"id" => id, "person" => person_params}) do
    person = People.get_person!(id)

    case People.update_person(person, person_params) do
      {:ok, person} ->
        user = conn.assigns[:current_user]
        ActivityLogs.log_person_action(:edit, person, user)

        conn
        |> put_flash(:info, "Person updated successfully.")
        |> redirect(to: ~p"/people/#{person}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, person: person, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    person = People.get_person!(id)
    {:ok, _person} = People.delete_person(person)

    user = conn.assigns[:current_user]
    ActivityLogs.log_person_action(:remove, person, user)

    conn
    |> put_flash(:info, "Person deleted successfully.")
    |> redirect(to: ~p"/people")
  end
end
