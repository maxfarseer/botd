defmodule BotdWeb.PersonController do
  use BotdWeb, :controller
  alias Botd.People

  def index(conn, _params) do
    people = People.list_people()
    render(conn, :index, people: people)
  end

  def show(conn, %{"id" => id}) do
    person = People.get_person!(id)
    render(conn, :show, person: person)
  end
end
