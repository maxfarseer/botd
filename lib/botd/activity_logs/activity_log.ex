defmodule Botd.ActivityLogs.ActivityLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activity_logs" do
    field :action, Ecto.Enum, values: [:create, :edit, :remove]
    field :entity_type, :string
    field :entity_id, :integer
    field :entity_name, :string
    field :user_id, :integer
    field :user_email, :string

    timestamps()
  end

  def changeset(activity_log, attrs) do
    activity_log
    |> cast(attrs, [:action, :entity_type, :entity_id, :entity_name, :user_id, :user_email])
    |> validate_required([:action, :entity_type, :entity_id, :entity_name])
  end
end
