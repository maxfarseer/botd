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

    # Create users with different roles
    admin_params = %{
      email: "admin@example.com",
      password: "secret1234",
      password_confirmation: "secret1234",
      role: :admin
    }

    moderator_params = %{
      email: "moderator@example.com",
      password: "secret1234",
      password_confirmation: "secret1234",
      role: :moderator
    }

    member_params = %{
      email: "member@example.com",
      password: "secret1234",
      password_confirmation: "secret1234",
      role: :member
    }

    {:ok, admin} = %User{} |> User.changeset(admin_params) |> Repo.insert()
    {:ok, moderator} = %User{} |> User.changeset(moderator_params) |> Repo.insert()
    {:ok, member} = %User{} |> User.changeset(member_params) |> Repo.insert()

    %{person: person, admin: admin, moderator: moderator, member: member}
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
        |> Pow.Plug.assign_current_user(member, otp_app: :botd)
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
        |> Pow.Plug.assign_current_user(admin, otp_app: :botd)
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
        |> Pow.Plug.assign_current_user(moderator, otp_app: :botd)
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
