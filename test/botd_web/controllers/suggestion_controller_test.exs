defmodule BotdWeb.SuggestionControllerTest do
  use BotdWeb.ConnCase

  alias Botd.AccountsFixtures
  alias Botd.People
  alias Botd.Suggestions

  setup do
    # Create users with different roles
    member_user = AccountsFixtures.user_fixture(%{email: "member@users.com", role: :member})
    admin_user = AccountsFixtures.user_fixture(%{email: "admin@users.com", role: :admin})

    moderator_user =
      AccountsFixtures.user_fixture(%{email: "moderator@users.com", role: :moderator})

    # Create a suggestion from the member
    {:ok, suggestion} =
      Suggestions.create_suggestion(
        %{
          "name" => "Test Person",
          "death_date" => ~D[2023-01-01],
          "place" => "Test City"
        },
        member_user
      )

    valid_attrs = %{
      "suggestion" => %{
        "name" => "New Test Person",
        "death_date" => "2023-02-02",
        "place" => "New Test City"
      }
    }

    # Invalid suggestion params for tests
    invalid_attrs = %{
      "suggestion" => %{
        # Name is required
        "name" => "",
        "death_date" => "invalid-date",
        "place" => "New Test City"
      }
    }

    %{
      admin: admin_user,
      moderator: moderator_user,
      member: member_user,
      suggestion: suggestion,
      valid_attrs: valid_attrs,
      invalid_attrs: invalid_attrs
    }
  end

  describe "new" do
    test "renders form for new suggestion", %{conn: conn, member: member} do
      conn =
        conn
        |> log_in_user(member)
        |> get(~p"/suggestions/new")

      assert html_response(conn, 200) =~ "Suggest a New Person"
    end

    test "redirects if not logged in", %{conn: conn} do
      conn = get(conn, ~p"/suggestions/new")
      assert redirected_to(conn) =~ "/users/log_in"
    end
  end

  describe "create" do
    test "redirect after creating suggestion", %{
      conn: conn,
      member: member,
      valid_attrs: valid_attrs
    } do
      suggestions_before = Suggestions.list_user_suggestions(member)

      conn =
        conn
        |> log_in_user(member)
        |> post(~p"/suggestions", valid_attrs)

      assert redirected_to(conn) =~ "/suggestions/my"

      suggestions_after = Suggestions.list_user_suggestions(member)
      [new_suggestion] = suggestions_after -- suggestions_before

      assert new_suggestion.name == valid_attrs["suggestion"]["name"]
      assert new_suggestion.place == valid_attrs["suggestion"]["place"]

      assert new_suggestion.death_date ==
               Date.from_iso8601!(valid_attrs["suggestion"]["death_date"])
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      member: member,
      invalid_attrs: invalid_attrs
    } do
      conn =
        conn
        |> log_in_user(member)
        |> post(~p"/suggestions", invalid_attrs)

      assert html_response(conn, 200) =~ "Suggest a New Person"
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "redirects if not logged in", %{conn: conn, valid_attrs: valid_attrs} do
      conn = post(conn, ~p"/suggestions", valid_attrs)
      assert redirected_to(conn) =~ "/users/log_in"
    end
  end

  describe "my_suggestions" do
    test "lists user's suggestions", %{conn: conn, member: member, suggestion: suggestion} do
      conn =
        conn
        |> log_in_user(member)
        |> get(~p"/suggestions/my")

      assert html_response(conn, 200) =~ "My Suggestions"
      assert html_response(conn, 200) =~ suggestion.name
    end

    test "redirects if not logged in", %{conn: conn} do
      conn = get(conn, ~p"/suggestions/my")
      assert redirected_to(conn) =~ "/users/log_in"
    end
  end

  describe "index (for moderators & admin)" do
    test "lists all pending suggestions for admin", %{
      conn: conn,
      admin: admin,
      suggestion: suggestion
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> get(~p"/protected/suggestions")

      assert html_response(conn, 200) =~ "Pending Suggestions"
      assert html_response(conn, 200) =~ suggestion.name
    end

    test "lists all pending suggestions for moderator", %{
      conn: conn,
      moderator: moderator,
      suggestion: suggestion
    } do
      conn =
        conn
        |> log_in_user(moderator)
        |> get(~p"/protected/suggestions")

      assert html_response(conn, 200) =~ "Pending Suggestions"
      assert html_response(conn, 200) =~ suggestion.name
    end

    test "redirects if logged in as regular member", %{conn: conn, member: member} do
      conn =
        conn
        |> log_in_user(member)
        |> get(~p"/protected/suggestions")

      assert redirected_to(conn) == "/"
    end

    test "redirects if not logged in", %{conn: conn} do
      conn = get(conn, ~p"/protected/suggestions")
      assert redirected_to(conn) =~ "/users/log_in"
    end
  end

  describe "show" do
    test "shows suggestion details for admin", %{conn: conn, admin: admin, suggestion: suggestion} do
      conn =
        conn
        |> log_in_user(admin)
        |> get(~p"/protected/suggestions/#{suggestion}")

      assert html_response(conn, 200) =~ suggestion.name
      assert html_response(conn, 200) =~ "Approve"
      assert html_response(conn, 200) =~ "Reject"
    end

    test "shows suggestion details for moderator", %{
      conn: conn,
      moderator: moderator,
      suggestion: suggestion
    } do
      conn =
        conn
        |> log_in_user(moderator)
        |> get(~p"/protected/suggestions/#{suggestion}")

      assert html_response(conn, 200) =~ suggestion.name
      assert html_response(conn, 200) =~ "Approve"
      assert html_response(conn, 200) =~ "Reject"
    end

    test "restricts access for regular member", %{
      conn: conn,
      member: member,
      suggestion: suggestion
    } do
      conn =
        conn
        |> log_in_user(member)
        |> get(~p"/protected/suggestions/#{suggestion}")

      assert redirected_to(conn) == "/"
    end
  end

  describe "approve" do
    test "approves suggestion and creates person for admin", %{
      conn: conn,
      admin: admin,
      suggestion: suggestion
    } do
      conn =
        conn
        |> log_in_user(admin)
        |> post(~p"/protected/suggestions/#{suggestion}/approve")

      # Verify person was created in database
      %{entries: entries} = People.list_people()
      [person] = entries
      assert person.name == suggestion.name
      assert person.death_date == suggestion.death_date
      assert person.place == suggestion.place

      # Verify suggestion status was updated
      updated_suggestion = Suggestions.get_suggestion!(suggestion.id)
      assert updated_suggestion.status == :approved
      assert updated_suggestion.reviewed_by_id == admin.id

      # Verify redirect
      assert redirected_to(conn) =~ "/people/#{person.id}"
    end

    test "restricts access for regular member", %{
      conn: conn,
      member: member,
      suggestion: suggestion
    } do
      conn =
        conn
        |> log_in_user(member)
        |> post(~p"/protected/suggestions/#{suggestion}/approve")

      assert redirected_to(conn) == "/"

      # Verify suggestion status was not changed
      updated_suggestion = Suggestions.get_suggestion!(suggestion.id)
      assert updated_suggestion.status == :pending
    end
  end

  describe "reject" do
    test "rejects suggestion for admin", %{conn: conn, admin: admin, suggestion: suggestion} do
      conn =
        conn
        |> log_in_user(admin)
        |> post(~p"/protected/suggestions/#{suggestion}/reject", %{"notes" => "Not suitable"})

      updated_suggestion = Suggestions.get_suggestion!(suggestion.id)
      assert updated_suggestion.status == :rejected
      assert updated_suggestion.notes == "Not suitable"
      assert updated_suggestion.reviewed_by_id == admin.id

      assert redirected_to(conn) == "/protected/suggestions"
    end

    test "restricts access for regular member", %{
      conn: conn,
      member: member,
      suggestion: suggestion
    } do
      conn =
        conn
        |> log_in_user(member)
        |> post(~p"/protected/suggestions/#{suggestion}/reject", %{"notes" => "Not suitable"})

      assert redirected_to(conn) == "/"

      # Verify suggestion status was not changed
      updated_suggestion = Suggestions.get_suggestion!(suggestion.id)
      assert updated_suggestion.status == :pending
    end
  end
end
