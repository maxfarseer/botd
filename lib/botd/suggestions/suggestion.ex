defmodule Botd.Suggestions.Suggestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "suggestions" do
    field :name, :string
    field :death_date, :date
    field :place, :string
    field :status, Ecto.Enum, values: [:pending, :approved, :rejected], default: :pending
    field :notes, :string

    belongs_to :user, Botd.Users.User
    belongs_to :reviewed_by, Botd.Users.User

    timestamps()
  end

  def changeset(suggestion, attrs) do
    suggestion
    |> cast(attrs, [:name, :death_date, :place, :status, :notes, :user_id, :reviewed_by_id])
    |> validate_required([:name, :death_date, :place, :user_id])
  end
end
