defmodule BotdWeb.RouterTest do
  use BotdWeb.ConnCase, async: true
  alias Botd.People
  alias Botd.Repo
  alias Botd.Users.User

  setup do
    # Create a test person
    {:ok, person} =
      People.create_person(%{
        name: "Test Person",
        death_date: ~D[2023-01-01],
        place: "Test City"
      })

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

    valid_person_params = %{
      "person" => %{
        name: "New Test Person",
        death_date: "2023-02-02",
        place: "New Test City"
      }
    }

    %{
      person: person,
      admin: admin,
      moderator: moderator,
      member: member,
      valid_person_params: valid_person_params
    }
  end

  describe "public routes" do
    test "GET / returns 200", %{conn: conn} do
      conn = get(conn, "/")
      assert conn.status == 200
    end

    test "GET /people returns 200", %{conn: conn} do
      conn = get(conn, "/people")
      assert conn.status == 200
    end

    test "GET /people/:id returns 200", %{conn: conn, person: person} do
      conn = get(conn, "/people/#{person.id}")
      assert conn.status == 200
    end
  end

  describe "protected routes - unauthenticated" do
    test "GET /logs redirects to login", %{conn: conn} do
      conn = get(conn, "/admin/logs")
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end

    test "GET /people/:id/edit redirects to login", %{conn: conn, person: person} do
      conn = get(conn, "/protected/people/#{person.id}/edit")
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end

    test "POST /people redirects to login", %{conn: conn, valid_person_params: params} do
      conn = post(conn, "/protected/people", params)
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end

    test "PUT /people/:id redirects to login", %{
      conn: conn,
      person: person,
      valid_person_params: params
    } do
      conn = put(conn, "/protected/people/#{person.id}", params)
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end

    test "DELETE /people/:id redirects to login", %{conn: conn, person: person} do
      conn = delete(conn, "/protected/people/#{person.id}")
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end
  end

  describe "protected routes - authenticated as admin" do
    setup %{conn: conn, admin: admin} do
      conn =
        conn
        |> Pow.Plug.assign_current_user(admin, otp_app: :botd)

      %{conn: conn}
    end

    test "GET /logs returns 200", %{conn: conn} do
      conn = get(conn, "/admin/logs")
      assert conn.status == 200
    end
  end
end
