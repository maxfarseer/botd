defmodule Botd.ActivityLogs do
  import Ecto.Query, warn: false
  alias Botd.ActivityLogs.ActivityLog
  alias Botd.Repo

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
