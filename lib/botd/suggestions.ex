defmodule Botd.Suggestions do
  import Ecto.Query
  alias Botd.Repo
  alias Botd.Suggestions.Suggestion
  alias Botd.People

  def create_suggestion(attrs, user) do
    attrs = Map.put(attrs, "user_id", user.id)

    %Suggestion{}
    |> Suggestion.changeset(attrs)
    |> Repo.insert()
  end

  def list_user_suggestions(user) do
    Suggestion
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  # For admins

  def list_pending_suggestions do
    Suggestion
    |> where(status: :pending)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def get_suggestion!(id), do: Repo.get!(Suggestion, id) |> Repo.preload([:user, :reviewed_by])

  def approve_suggestion(suggestion, reviewer) do
    Repo.transaction(fn ->
      # 1. Update suggestion status
      {:ok, updated_suggestion} =
        suggestion
        |> Suggestion.changeset(%{
          status: :approved,
          reviewed_by_id: reviewer.id
        })
        |> Repo.update()

      # 2. Create person from suggestion
      {:ok, person} =
        People.create_person(%{
          name: suggestion.name,
          death_date: suggestion.death_date,
          place: suggestion.place
        })

      {updated_suggestion, person}
    end)
  end

  def reject_suggestion(suggestion, reviewer, notes \\ nil) do
    suggestion
    |> Suggestion.changeset(%{
      status: :rejected,
      reviewed_by_id: reviewer.id,
      notes: notes
    })
    |> Repo.update()
  end
end
