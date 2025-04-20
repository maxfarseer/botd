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
    user = conn.assigns[:current_user]

    with {:ok, person} <- People.create_person(person_params),
         {:ok, _log} <- ActivityLogs.log_person_action(:create_person, person, user) do
      conn
      |> put_flash(:info, "Person created successfully.")
      |> redirect(to: ~p"/people/#{person}")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, inspect_errors(changeset))
        |> redirect(to: ~p"/people/")

      {:error, _any_error} ->
        conn
        |> put_flash(:error, "Person: Something went wrong.")
        |> redirect(to: ~p"/people/")
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
    user = conn.assigns[:current_user]

    with {:ok, updated_person} <- People.update_person(person, person_params),
         {:ok, _log} <- ActivityLogs.log_person_action(:edit_person, updated_person, user) do
      conn
      |> put_flash(:info, "Person updated successfully.")
      |> redirect(to: ~p"/people/#{updated_person}")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, inspect_errors(changeset))
        |> redirect(to: ~p"/people/#{person}")

      {:error, _any_error} ->
        conn
        |> put_flash(:error, "Person: Something went wrong.")
        |> redirect(to: ~p"/people/#{person}")
    end
  end

  def delete(conn, %{"id" => id}) do
    person = People.get_person!(id)
    {:ok, _person} = People.delete_person(person)

    user = conn.assigns[:current_user]
    ActivityLogs.log_person_action(:remove_person, person, user)

    with {:ok, _person} <- People.delete_person(person),
         {:ok, _log} <- ActivityLogs.log_person_action(:remove_person, person, user) do
      conn
      |> put_flash(:info, "Person deleted successfully.")
      |> redirect(to: ~p"/people")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, inspect_errors(changeset))
        |> redirect(to: ~p"/people/#{person}")

      {:error, _any_error} ->
        conn
        |> put_flash(:error, "Person: Something went wrong.")
        |> redirect(to: ~p"/people")
    end
  end
end
