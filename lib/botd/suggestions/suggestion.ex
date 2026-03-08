defmodule Botd.Suggestions.Suggestion do
  @moduledoc """
  The Suggestion schema and changeset functions.

  This module defines the database schema for user-submitted suggestions
  for new people to be added to the Book of the Dead. It includes fields
  for the suggested person's information, the status of the suggestion,
  and tracking of who submitted and reviewed it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:pending, :approved, :rejected]

  #TODO: check string vs enum
  @sources ["web", "telegram", "vk"]

  schema "suggestions" do
    field :name, :string
    field :death_date, :date
    field :place, :string
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :notes, :string
    field :telegram_username, :string
    field :photo_url, :string
    field :photos, {:array, :string}
    field :source, :string, default: "web"
    field :vk_post_id, :integer
    field :vk_owner_id, :integer

    belongs_to :user, Botd.Accounts.User
    belongs_to :reviewed_by, Botd.Accounts.User

    timestamps()
  end

  def changeset(suggestion, attrs) do
    suggestion
    |> cast(attrs, [
      :name,
      :death_date,
      :place,
      :status,
      :notes,
      :user_id,
      :reviewed_by_id,
      :telegram_username,
      :photo_url,
      :photos,
      :source,
      :vk_post_id,
      :vk_owner_id
    ])
    |> validate_required([:name, :death_date, :user_id])
    |> validate_length(:telegram_username, max: 200)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:source, @sources)
  end
end
