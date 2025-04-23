defmodule Botd.ActivityLogs do
  @moduledoc """
  The ActivityLogs context.

  This context provides functions for managing activity logs, including
  creating, retrieving, and querying logs of user actions within the system.

  Activity logs track who did what and when, providing an audit trail of
  operations performed on entities like people.

  Example:

      # Log a create action
      Botd.ActivityLogs.log_person_action(:create, person, current_user)

      # List all activity logs
      logs = Botd.ActivityLogs.list_activity_logs()

  Example and @doc for `list_activity_logs` fn remained in this module, check later auto-generated docs to decide what to keep.
  """
  import Ecto.Query, warn: false
  alias Botd.ActivityLogs.ActivityLog
  alias Botd.Repo

  @doc """
  Returns a list of all activity logs, sorted by insertion date (newest first).
  """
  def list_activity_logs(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    query = from(log in ActivityLog, order_by: [desc: log.inserted_at])

    # paginate comes from Scrivener
    Repo.paginate(query, page: page, page_size: per_page)
  end

  def get_activity_log!(id), do: Repo.get!(ActivityLog, id)

  def create_activity_log(attrs \\ %{}) do
    %ActivityLog{}
    |> ActivityLog.changeset(attrs)
    |> Repo.insert()
  end

  def log_person_action(action, person, user)
      when action in [:create_person, :create_person_via_suggestion, :edit_person, :remove_person] do
    attrs =
      %{
        action: action,
        entity_type: "person",
        entity_id: person.id,
        user_id: user.id
      }

    create_activity_log(attrs)
  end

  # Question to Samu: can I have suggestion type somehow?
  # if i type suggestion. -> it should suggest me user autocomplete
  def log_suggestion_action(action, suggestion)
      when action in [:approve_suggestion, :reject_suggestion] do
    attrs =
      %{
        action: action,
        entity_type: "suggestion",
        entity_id: suggestion.id,
        user_id: suggestion.reviewed_by_id
      }

    create_activity_log(attrs)
  end
end
