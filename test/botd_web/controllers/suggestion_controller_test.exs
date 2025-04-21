defmodule BotdWeb.SuggestionControllerTest do
  use BotdWeb.ConnCase

  alias Botd.Suggestions
  # alias Botd.Suggestions.Suggestion
  # alias Botd.People
  # alias Botd.ActivityLogs
  alias Botd.Users.User
  alias Botd.Repo

  setup do
    # Create users with different roles
    member_user =
      %User{
        id: 1,
        email: "member@users.com",
        role: :member
      }
      |> Repo.insert!()

    admin_user =
      %User{
        id: 2,
        email: "admin@users.com",
        role: :admin
      }
      |> Repo.insert!()

    moderator_user =
      %User{
        id: 3,
        email: "moderator@users.com",
        role: :moderator
      }
      |> Repo.insert!()

    # Create a suggestion from the member
    {:ok, suggestion} =
      Suggestions.create_suggestion(
        %{
          name: "Test Person",
          death_date: ~D[2023-01-01],
          place: "Test City"
        },
        member_user
      )

    # Valid suggestion params for tests
    valid_attrs = %{
      suggestion: %{
        name: "New Test Person",
        death_date: "2023-02-02",
        place: "New Test City"
      }
    }

    # Invalid suggestion params for tests
    invalid_attrs = %{
      suggestion => %{
        # Name is required
        name: "",
        death_date: "invalid-date",
        place: "New Test City"
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
        |> Pow.Plug.assign_current_user(member, otp_app: :botd)
        |> get(~p"/suggestions/new")

      assert html_response(conn, 200) =~ "Suggest a New Person"
    end

    test "redirects if not logged in", %{conn: conn} do
      conn = get(conn, ~p"/suggestions/new")
      assert redirected_to(conn) =~ "/session/new"
    end
  end

  describe "create" do
    # test "creates suggestion when data is valid", %{
    #   conn: conn,
    #   member: member,
    #   valid_attrs: valid_attrs
    # } do
    #   conn =
    #     conn
    #     |> Pow.Plug.assign_current_user(member, otp_app: :botd)
    #     |> post(~p"/suggestions", valid_attrs)

    #   IO.inspect(conn, label: "conn")

    #   assert %{to: path} = redirected_to(conn)
    #   assert path == "/suggestions/my"

    #   # Check suggestion was created
    #   [suggestion | _] = Suggestions.list_user_suggestions(member)
    #   assert suggestion.name == valid_attrs["suggestion"].name
    #   assert suggestion.place == valid_attrs["suggestion"].place
    # end

    # test "renders errors when data is invalid", %{
    #   conn: conn,
    #   member: member,
    #   invalid_attrs: invalid_attrs
    # } do
    #   conn =
    #     conn
    #     |> Pow.Plug.assign_current_user(member, otp_app: :botd)
    #     |> post(~p"/suggestions", invalid_attrs)

    #   assert html_response(conn, 200) =~ "New Suggestion"
    #   assert html_response(conn, 200) =~ "can't be blank"
    # end

    # test "redirects if not logged in", %{conn: conn, valid_attrs: valid_attrs} do
    #   conn = post(conn, ~p"/suggestions", valid_attrs)
    #   assert redirected_to(conn) =~ "/session/new"
    # end
  end

  describe "my_suggestions" do
    test "lists user's suggestions", %{conn: conn, member: member, suggestion: suggestion} do
      conn =
        conn
        |> Pow.Plug.assign_current_user(member, otp_app: :botd)
        |> get(~p"/suggestions/my")

      assert html_response(conn, 200) =~ "My Suggestions"
      assert html_response(conn, 200) =~ suggestion.name
    end

    test "redirects if not logged in", %{conn: conn} do
      conn = get(conn, ~p"/suggestions/my")
      assert redirected_to(conn) =~ "/session/new"
    end
  end

  describe "index (for moderators)" do
    test "lists all pending suggestions for admin", %{
      conn: conn,
      admin: admin,
      suggestion: suggestion
    } do
      conn =
        conn
        |> Pow.Plug.assign_current_user(admin, otp_app: :botd)
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
        |> Pow.Plug.assign_current_user(moderator, otp_app: :botd)
        |> get(~p"/protected/suggestions")

      assert html_response(conn, 200) =~ "Pending Suggestions"
      assert html_response(conn, 200) =~ suggestion.name
    end

    test "redirects if logged in as regular member", %{conn: conn, member: member} do
      conn =
        conn
        |> Pow.Plug.assign_current_user(member, otp_app: :botd)
        |> get(~p"/protected/suggestions")

      assert redirected_to(conn) == "/"
      # TODO:max deprecated, use Phoenix.Flash.get
      assert get_flash(conn, :error) =~ "don't have permission"
    end

    test "redirects if not logged in", %{conn: conn} do
      conn = get(conn, ~p"/protected/suggestions")
      assert redirected_to(conn) =~ "/session/new"
    end
  end

  describe "show" do
    test "shows suggestion details for admin", %{conn: conn, admin: admin, suggestion: suggestion} do
      conn =
        conn
        |> Pow.Plug.assign_current_user(admin, otp_app: :botd)
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
        |> Pow.Plug.assign_current_user(moderator, otp_app: :botd)
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
        |> Pow.Plug.assign_current_user(member, otp_app: :botd)
        |> get(~p"/protected/suggestions/#{suggestion}")

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "don't have permission"
    end
  end

  describe "approve" do
    # test "approves suggestion and creates person for admin", %{
    #   conn: conn,
    #   admin: admin,
    #   suggestion: suggestion
    # } do
    #   # Mock the ActivityLogs functions to avoid errors
    #   expect(ActivityLogs, :log_suggestion_action, fn _, _ -> {:ok, %{}} end)
    #   expect(ActivityLogs, :log_person_action, fn _, _, _ -> {:ok, %{}} end)

    #   conn =
    #     conn
    #     |> Pow.Plug.assign_current_user(admin, otp_app: :botd)
    #     |> post(~p"/protected/suggestions/#{suggestion}/approve")

    #   # Verify person was created in database
    #   [person] = People.list_people()
    #   assert person.name == suggestion.name
    #   assert person.death_date == suggestion.death_date
    #   assert person.place == suggestion.place

    #   # Verify suggestion status was updated
    #   updated_suggestion = Suggestions.get_suggestion!(suggestion.id)
    #   assert updated_suggestion.status == :approved
    #   assert updated_suggestion.reviewed_by_id == admin.id

    #   # Verify redirect
    #   assert redirected_to(conn) =~ "/people/#{person.id}"
    #   assert get_flash(conn, :info) =~ "approved"
    # end

    test "restricts access for regular member", %{
      conn: conn,
      member: member,
      suggestion: suggestion
    } do
      conn =
        conn
        |> Pow.Plug.assign_current_user(member, otp_app: :botd)
        |> post(~p"/protected/suggestions/#{suggestion}/approve")

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "don't have permission"

      # Verify suggestion status was not changed
      updated_suggestion = Suggestions.get_suggestion!(suggestion.id)
      assert updated_suggestion.status == :pending
    end
  end

  describe "reject" do
    # test "rejects suggestion for admin", %{conn: conn, admin: admin, suggestion: suggestion} do
    #   # Mock the ActivityLogs.log_suggestion_action function
    #   expect(ActivityLogs, :log_suggestion_action, fn _, _ -> {:ok, %{}} end)

    #   conn =
    #     conn
    #     |> Pow.Plug.assign_current_user(admin, otp_app: :botd)
    #     |> post(~p"/protected/suggestions/#{suggestion}/reject", %{"notes" => "Not suitable"})

    #   # Verify suggestion status was updated
    #   updated_suggestion = Suggestions.get_suggestion!(suggestion.id)
    #   assert updated_suggestion.status == :rejected
    #   assert updated_suggestion.notes == "Not suitable"
    #   assert updated_suggestion.reviewed_by_id == admin.id

    #   # Verify redirect
    #   assert redirected_to(conn) == "/protected/suggestions"
    #   assert get_flash(conn, :info) =~ "rejected"
    # end

    test "restricts access for regular member", %{
      conn: conn,
      member: member,
      suggestion: suggestion
    } do
      conn =
        conn
        |> Pow.Plug.assign_current_user(member, otp_app: :botd)
        |> post(~p"/protected/suggestions/#{suggestion}/reject", %{"notes" => "Not suitable"})

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "don't have permission"

      # Verify suggestion status was not changed
      updated_suggestion = Suggestions.get_suggestion!(suggestion.id)
      assert updated_suggestion.status == :pending
    end
  end

  # Helper functions
  # defp expect(module, function, expectation) do
  #   # In a real test, you would use Mox or similar to mock functions
  #   # This is just a placeholder that doesn't do anything
  #   # Replace with actual mocking if needed
  #   :ok
  # end
end
