defmodule BotdWeb.PersonHTMLTest do
  use BotdWeb.ConnCase, async: true

  alias Botd.People
  alias Botd.Repo
  alias Botd.Users.User

  setup do
    person_attrs = %{
      name: "Test Person",
      death_date: ~D[2020-01-01],
      place: "Test City"
    }

    {:ok, person} = People.create_person(person_attrs)

    user_params = %{
      email: "test@example.com",
      password: "secret1234",
      password_confirmation: "secret1234"
    }

    {:ok, user} = %User{} |> User.changeset(user_params) |> Repo.insert()

    %{person: person, user: user}
  end

  describe "Person show.html" do
    test "hide Edit and Delete buttons for unauthenticated users", %{
      conn: conn,
      person: person
    } do
      conn = get(conn, ~p"/people/#{person}")

      assert html_response(conn, 200) =~ person.name

      html = html_response(conn, 200)
      {:ok, document} = Floki.parse_document(html)

      edit_button = Floki.find(document, "[data-test-id='edit-person']")
      assert edit_button == []

      delete_button = Floki.find(document, "[data-test-id='remove-person']")
      assert delete_button == []
    end

    test "shows Edit and Delete buttons for authenticated users", %{
      conn: conn,
      person: person,
      user: user
    } do
      conn =
        conn
        |> Pow.Plug.assign_current_user(user, otp_app: :my_app)
        |> get(~p"/people/#{person}")

      assert html_response(conn, 200) =~ person.name

      html = html_response(conn, 200)
      {:ok, document} = Floki.parse_document(html)

      edit_button = Floki.find(document, "[data-test-id='edit-person']")
      assert edit_button != []

      delete_button = Floki.find(document, "[data-test-id='remove-person']")
      assert delete_button != []
    end
  end
end
