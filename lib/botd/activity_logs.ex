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
  def list_activity_logs do
    Repo.all(from l in ActivityLog, order_by: [desc: l.inserted_at])
  end

  def get_activity_log!(id), do: Repo.get!(ActivityLog, id)

  def create_activity_log(attrs \\ %{}) do
    %ActivityLog{}
    |> ActivityLog.changeset(attrs)
    |> Repo.insert()
  end

  def log_person_action(action, person, user) when action in [:create, :edit, :remove] do
    user_info = if user, do: %{user_id: user.id, user_email: user.email}, else: %{}

    attrs =
      %{
        action: action,
        entity_type: "person",
        entity_id: person.id,
        entity_name: person.name
      }
      |> Map.merge(user_info)

    create_activity_log(attrs)
  end
end
