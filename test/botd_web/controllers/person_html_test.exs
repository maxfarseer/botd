defmodule BotdWeb.PersonHTMLTest do
  use BotdWeb.ConnCase, async: true

  alias Botd.AccountsFixtures
  alias Botd.People

  setup do
    person_attrs = %{
      name: "Test Person",
      death_date: ~D[2020-01-01],
      place: "Test City"
    }

    {:ok, person} = People.create_person(person_attrs)

    member_user = AccountsFixtures.user_fixture(%{email: "member@users.com", role: :member})
    admin_user = AccountsFixtures.user_fixture(%{email: "admin@users.com", role: :admin})

    moderator_user =
      AccountsFixtures.user_fixture(%{email: "moderator@users.com", role: :moderator})

    %{person: person, admin: admin_user, moderator: moderator_user, member: member_user}
  end

  describe "Person show.html" do
    test "hides Edit and Delete buttons for unauthenticated users", %{
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

    test "hides Edit and Delete buttons for regular members", %{
      conn: conn,
      person: person,
      member: member
    } do
      conn =
        conn
        |> log_in_user(member)
        |> get(~p"/people/#{person}")

      assert html_response(conn, 200) =~ person.name

      html = html_response(conn, 200)
      {:ok, document} = Floki.parse_document(html)

      edit_button = Floki.find(document, "[data-test-id='edit-person']")
      assert edit_button == []

      delete_button = Floki.find(document, "[data-test-id='remove-person']")
      assert delete_button == []
    end

    test "shows Edit and Delete buttons for admin users", %{
      conn: conn,
      person: person,
      admin: admin
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> get(~p"/people/#{person}")

      assert html_response(conn, 200) =~ person.name

      html = html_response(conn, 200)
      {:ok, document} = Floki.parse_document(html)

      edit_button = Floki.find(document, "[data-test-id='edit-person']")
      assert edit_button != []

      delete_button = Floki.find(document, "[data-test-id='remove-person']")
      assert delete_button != []
    end

    test "shows Edit and Delete buttons for moderator users", %{
      conn: conn,
      person: person,
      moderator: moderator
    } do
      conn =
        conn
        |> log_in_user(moderator)
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
