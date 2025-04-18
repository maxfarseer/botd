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

  @actions [
    :create_person,
    :create_person_via_suggestion,
    :edit_person,
    :remove_person,
    :create_suggestion,
    :edit_suggestion,
    :remove_suggestion,
    :approve_suggestion,
    :reject_suggestion
  ]
  @entity_types [:person, :suggestion]

  schema "activity_logs" do
    field :action, Ecto.Enum, values: @actions
    field :entity_id, :integer
    field :entity_type, Ecto.Enum, values: @entity_types
    field :user_id, :integer

    timestamps()
  end

  def changeset(activity_log, attrs) do
    activity_log
    |> cast(attrs, [:action, :entity_id, :entity_type, :user_id])
    |> validate_required([:action, :entity_type, :entity_id, :user_id])
    |> validate_inclusion(:entity_type, @entity_types)
    |> validate_inclusion(:action, @actions)
  end
end
