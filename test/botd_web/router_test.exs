defmodule BotdWeb.RouterTest do
  use BotdWeb.ConnCase, async: true
  alias Botd.People
  alias Botd.Repo
  alias Botd.Users.User

  setup do
    # Create a person for testing
    {:ok, person} =
      People.create_person(%{
        name: "Test Person",
        death_date: ~D[2023-01-01],
        place: "Test City"
      })

    # Create a user for testing
    user_params = %{
      email: "test@example.com",
      password: "secret1234",
      password_confirmation: "secret1234"
    }

    {:ok, user} = %User{} |> User.changeset(user_params) |> Repo.insert()

    # Valid person params for creation and update tests
    valid_person_params = %{
      "person" => %{
        name: "New Test Person",
        death_date: "2023-02-02",
        place: "New Test City"
      }
    }

    %{person: person, user: user, valid_person_params: valid_person_params}
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

    test "GET /people/new returns 200", %{conn: conn} do
      conn = get(conn, "/people/new")
      assert conn.status == 200
    end

    test "GET /people/:id returns 200", %{conn: conn, person: person} do
      conn = get(conn, "/people/#{person.id}")
      assert conn.status == 200
    end
  end

  describe "protected routes - unauthenticated" do
    test "GET /logs redirects to login", %{conn: conn} do
      conn = get(conn, "/logs")
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end

    test "GET /people/:id/edit redirects to login", %{conn: conn, person: person} do
      conn = get(conn, "/people/#{person.id}/edit")
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end

    test "POST /people redirects to login", %{conn: conn, valid_person_params: params} do
      conn = post(conn, "/people", params)
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end

    test "PUT /people/:id redirects to login", %{
      conn: conn,
      person: person,
      valid_person_params: params
    } do
      conn = put(conn, "/people/#{person.id}", params)
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end

    test "DELETE /people/:id redirects to login", %{conn: conn, person: person} do
      conn = delete(conn, "/people/#{person.id}")
      assert conn.status == 302
      assert redirected_to(conn) =~ "/session/new"
    end
  end

  describe "protected routes - authenticated" do
    setup %{conn: conn, user: user} do
      conn =
        conn
        |> Pow.Plug.assign_current_user(user, otp_app: :botd)

      %{conn: conn}
    end

    test "GET /logs returns 200", %{conn: conn} do
      conn = get(conn, "/logs")
      assert conn.status == 200
    end

    test "GET /people/:id/edit returns 200", %{conn: conn, person: person} do
      conn = get(conn, "/people/#{person.id}/edit")
      assert conn.status == 200
    end

    test "POST /people creates a person and redirects", %{conn: conn, valid_person_params: params} do
      conn = post(conn, "/people", params)
      assert conn.status == 302
      assert redirected_to(conn) =~ "/people/"
      # The path should include the ID of the newly created person
      assert Regex.match?(~r{/people/\d+}, redirected_to(conn))
    end

    test "PUT /people/:id updates a person and redirects", %{
      conn: conn,
      person: person,
      valid_person_params: params
    } do
      conn = put(conn, "/people/#{person.id}", params)
      assert conn.status == 302
      assert redirected_to(conn) == "/people/#{person.id}"

      # Verify the person was updated
      updated_person = People.get_person!(person.id)
      assert updated_person.name == params["person"].name
    end

    test "DELETE /people/:id removes a person and redirects", %{conn: conn, person: person} do
      conn = delete(conn, "/people/#{person.id}")
      assert conn.status == 302
      assert redirected_to(conn) == "/people"

      # Verify the person was deleted
      assert_raise Ecto.NoResultsError, fn ->
        People.get_person!(person.id)
      end
    end
  end
end
