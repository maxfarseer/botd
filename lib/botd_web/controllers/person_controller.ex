defmodule BotdWeb.PersonController do
  use BotdWeb, :controller
  alias Botd.ActivityLogs
  alias Botd.People
  alias Botd.People.Person

  def index(conn, params) do
    page = params["page"] || "1"
    per_page = params["per_page"] || "10"

    {page, _} = Integer.parse(page)
    {per_page, _} = Integer.parse(per_page)

    %{entries: people, page_number: page_number, total_pages: total_pages} =
      People.list_people(page: page, per_page: per_page)

    render(conn, :index,
      people: people,
      page_number: page_number,
      total_pages: total_pages,
      per_page: per_page
    )
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
    person = People.get_person!(id) |> Botd.Repo.preload(:photos)
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
        |> redirect(to: ~p"/people")

      {:error, _any_error} ->
        conn
        |> put_flash(:error, "Person: Something went wrong.")
        |> redirect(to: ~p"/people")
    end
  end
end
