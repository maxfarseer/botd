defmodule Botd.Suggestions do
  @moduledoc """
  The Suggestions context.

  This module provides functions for managing user-submitted suggestions
  for new people to add to the Book of the Dead. It handles the entire
  suggestion lifecycle including creation, listing, approval, and rejection.

  Suggestions go through a moderation workflow where admins and moderators
  can approve or reject submissions from regular users.
  """

  import Ecto.Query
  alias Botd.Adapters.VKApiAdapter
  alias Botd.People
  alias Botd.Repo
  alias Botd.Suggestions.Suggestion
  require Logger

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
          place: suggestion.place,
          photo_url: suggestion.photo_url
        })

      # 3. Save photos
      _photos =
        (suggestion.photos || [])
        |> Enum.map(fn url ->
          People.create_photo(%{
            url: url,
            person_id: person.id,
            size: "large"
          })
        end)

      {updated_suggestion, person}
    end)
    |> tap(fn
      {:ok, _} -> maybe_publish_vk_post(suggestion)
      _ -> :ok
    end)
  end

  def reject_suggestion(suggestion, reviewer, notes \\ nil) do
    result =
      suggestion
      |> Suggestion.changeset(%{
        status: :rejected,
        reviewed_by_id: reviewer.id,
        notes: notes
      })
      |> Repo.update()

    if match?({:ok, _}, result), do: maybe_delete_vk_post(suggestion)

    result
  end

  defp maybe_publish_vk_post(%{source: "vk", vk_post_id: post_id, vk_owner_id: owner_id})
       when not is_nil(post_id) and not is_nil(owner_id) do
    token = System.get_env("VK_ACCESS_TOKEN", "")

    case VKApiAdapter.publish_post(token, owner_id, post_id) do
      {:ok, _} ->
        Logger.info("VK: published post id=#{post_id}")

      {:error, reason} ->
        Logger.error("VK: failed to publish post id=#{post_id}: #{inspect(reason)}")
    end
  end

  defp maybe_publish_vk_post(_), do: :ok

  defp maybe_delete_vk_post(%{source: "vk", vk_post_id: post_id, vk_owner_id: owner_id})
       when not is_nil(post_id) and not is_nil(owner_id) do
    token = System.get_env("VK_ACCESS_TOKEN", "")

    case VKApiAdapter.delete_post(token, owner_id, post_id) do
      {:ok, _} ->
        Logger.info("VK: deleted post id=#{post_id}")

      {:error, reason} ->
        Logger.error("VK: failed to delete post id=#{post_id}: #{inspect(reason)}")
    end
  end

  defp maybe_delete_vk_post(_), do: :ok
end
