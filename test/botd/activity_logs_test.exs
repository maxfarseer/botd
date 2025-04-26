defmodule Botd.ActivityLogsTest do
  use Botd.DataCase

  alias Botd.ActivityLogs
  alias Botd.People.Person
  alias Botd.Repo
  alias Botd.Suggestions.Suggestion
  alias Botd.Users.User

  describe "activity_logs" do
    setup do
      user =
        %User{
          id: 1,
          email: "test@example.com",
          role: :member
        }
        |> Repo.insert!()

      admin_user =
        %User{
          id: 2,
          email: "admin@example.com",
          role: :admin
        }
        |> Repo.insert!()

      {:ok, person} =
        %Person{}
        |> Person.changeset(%{
          name: "Test Person",
          death_date: ~D[2023-01-01],
          place: "Test City"
        })
        |> Repo.insert()

      suggestion =
        %Suggestion{
          id: 1,
          name: "Test Suggestion",
          death_date: ~D[2023-01-01],
          place: "Test City",
          status: :pending,
          user: user,
          reviewed_by_id: admin_user.id
        }
        |> Repo.insert!()

      # %{user: user, person: person, suggestion: suggestion}
      %{user: user, person: person, suggestion: suggestion, admin_user: admin_user}
    end

    test "list_activity_logs/1 returns paginated activity logs", %{
      user: user,
      person: person
    } do
      # Create multiple activity logs
      _logs =
        for _i <- 1..15 do
          {:ok, log} = ActivityLogs.log_person_action(:create_person, person, user)
          # Ensure logs have different timestamps
          :timer.sleep(5)
          log
        end

      # Test default pagination (page 1, default per_page)
      page1 = ActivityLogs.list_activity_logs()
      assert %{entries: logs, page_number: 1, total_pages: total_pages} = page1
      # default per_page
      assert length(logs) <= 10
      assert total_pages > 1

      # Test custom page and per_page
      page2 = ActivityLogs.list_activity_logs(page: 2, per_page: 5)
      assert %{entries: logs2, page_number: 2, total_pages: total_pages2} = page2
      assert length(logs2) <= 5
      # With 15 items and 5 per page
      assert total_pages2 >= 3
    end

    test "list_activity_logs/0 returns all activity logs ordered by insertion date", %{
      user: user,
      person: person
    } do
      # Create some activity logs
      {:ok, log1} = ActivityLogs.log_person_action(:create_person, person, user)
      # Ensure logs have different timestamps
      :timer.sleep(10)
      {:ok, log2} = ActivityLogs.log_person_action(:edit_person, person, user)

      %{entries: logs} = ActivityLogs.list_activity_logs()

      assert length(logs) >= 2
      assert Enum.find(logs, &(&1.id == log1.id))
      assert Enum.find(logs, &(&1.id == log2.id))

      # Verify order is newest first
      first_two_logs = Enum.take(logs, 2)
      [newer, older] = first_two_logs
      assert newer.inserted_at >= older.inserted_at
    end

    test "list_activity_logs/0 returns activity logs with user preloaded", %{
      user: user,
      person: person
    } do
      ActivityLogs.log_person_action(:create_person, person, user)
      %{entries: [first_log | _other]} = ActivityLogs.list_activity_logs()

      assert first_log.user.email == user.email
    end

    test "get_activity_log!/1 returns the log with given id", %{user: user, person: person} do
      {:ok, log} = ActivityLogs.log_person_action(:create_person, person, user)
      retrieved_log = ActivityLogs.get_activity_log!(log.id)
      assert retrieved_log.id == log.id
      assert retrieved_log.action == :create_person
      assert retrieved_log.entity_type == :person
      assert retrieved_log.entity_id == person.id
      assert retrieved_log.user_id == user.id
    end

    test "create_activity_log/1 creates a log with valid attributes" do
      valid_attrs = %{
        action: :create_person,
        entity_type: :person,
        entity_id: 42,
        user_id: 1
      }

      {:ok, log} = ActivityLogs.create_activity_log(valid_attrs)
      assert log.action == :create_person
      assert log.entity_type == :person
      assert log.entity_id == 42
      assert log.user_id == 1
    end

    test "create_activity_log/1 returns error with invalid attributes" do
      invalid_attrs = %{action: :invalid_action, entity_type: nil}
      assert {:error, %Ecto.Changeset{}} = ActivityLogs.create_activity_log(invalid_attrs)
    end

    test "log_person_action/3 logs actions for a person", %{user: user, person: person} do
      actions = [:create_person, :create_person_via_suggestion, :edit_person, :remove_person]

      for action <- actions do
        {:ok, log} = ActivityLogs.log_person_action(action, person, user)
        assert log.action == action
        assert log.entity_type == :person
        assert log.entity_id == person.id
        assert log.user_id == user.id
      end
    end

    test "log_suggestion_action/2 logs actions for a suggestion", %{
      suggestion: suggestion,
      admin_user: admin_user
    } do
      actions = [:approve_suggestion, :reject_suggestion]

      for action <- actions do
        {:ok, log} = ActivityLogs.log_suggestion_action(action, suggestion)
        assert log.action == action
        assert log.entity_type == :suggestion
        assert log.entity_id == suggestion.id
        assert log.user_id == admin_user.id
      end
    end
  end
end
