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
          user: user
        }
        |> Repo.insert!()

      # %{user: user, person: person, suggestion: suggestion}
      %{user: user, person: person, suggestion: suggestion}
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

      logs = ActivityLogs.list_activity_logs()

      assert length(logs) >= 2
      assert Enum.find(logs, &(&1.id == log1.id))
      assert Enum.find(logs, &(&1.id == log2.id))

      # Verify order is newest first
      first_two_logs = Enum.take(logs, 2)
      [newer, older] = first_two_logs
      assert newer.inserted_at >= older.inserted_at
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

    test "log_suggestion_action/3 logs actions for a suggestion", %{
      suggestion: suggestion
    } do
      actions = [:approve_suggestion, :reject_suggestion]

      for action <- actions do
        {:ok, log} = ActivityLogs.log_suggestion_action(action, suggestion)
        assert log.action == action
        assert log.entity_type == :suggestion
        assert log.entity_id == suggestion.id
        assert log.user_id == suggestion.user.id
      end
    end
  end
end
