defmodule Botd.ActivityLogs.ActivityLog do
  @moduledoc """
  The ActivityLog schema and changeset functions.

  This module defines the ActivityLog schema which tracks user activities
  in the system. It records actions like create, edit, and remove operations
  performed on entities, along with information about which user performed
  the action and when.

  ActivityLogs enable auditing, history tracking, and potentially undo
  functionality in the application.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "activity_logs" do
    field :action, :string
    field :entity_id, :integer
    field :user_id, :integer
    field :entity_type, :string

    timestamps()
  end

  def changeset(activity_log, attrs) do
    activity_log
    |> cast(attrs, [:action, :entity_type, :entity_id, :entity_name, :user_id, :user_email])
    |> validate_required([:action, :entity_type, :entity_id, :entity_name])
  end
end
