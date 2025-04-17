defmodule Botd.Suggestions.Suggestion do
  @moduledoc """
  The Suggestion schema and changeset functions.

  This module defines the database schema for user-submitted suggestions
  for new people to be added to the Book of the Dead. It includes fields
  for the suggested person's information, the status of the suggestion,
  and tracking of who submitted and reviewed it.

  Suggestions can have one of three statuses:
  - pending: awaiting moderator review
  - approved: accepted and converted to a person record
  - rejected: declined by a moderator with optional notes
  """

  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:pending, :approved, :rejected]

  schema "suggestions" do
    field :name, :string
    field :death_date, :date
    field :place, :string
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :notes, :string

    belongs_to :user, Botd.Users.User
    belongs_to :reviewed_by, Botd.Users.User

    timestamps()
  end

  def changeset(suggestion, attrs) do
    suggestion
    |> cast(attrs, [:name, :death_date, :place, :status, :notes, :user_id, :reviewed_by_id])
    |> validate_required([:name, :death_date, :place, :user_id])
    |> validate_inclusion(:status, @statuses)
  end
end
