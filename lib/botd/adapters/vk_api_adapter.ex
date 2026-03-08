defmodule Botd.Adapters.VKApiAdapter do
  @moduledoc """
  Adapter for VK community API operations.

  Used to publish or delete suggested posts in a VK community
  after moderation actions in the app.
  """

  @callback publish_post(token :: String.t(), owner_id :: integer(), post_id :: integer()) ::
              {:ok, any()} | {:error, any()}

  @callback delete_post(token :: String.t(), owner_id :: integer(), post_id :: integer()) ::
              {:ok, any()} | {:error, any()}

  def publish_post(token, owner_id, post_id), do: impl().publish_post(token, owner_id, post_id)

  def delete_post(token, owner_id, post_id), do: impl().delete_post(token, owner_id, post_id)

  defp impl, do: Application.get_env(:botd, :vk_api, Botd.Adapters.ExternalVKAPI)
end
