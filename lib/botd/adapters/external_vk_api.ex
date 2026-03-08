defmodule Botd.Adapters.ExternalVKAPI do
  @moduledoc """
  Production implementation of the VK API adapter.

  Calls the VK API to publish or delete suggested posts in a community.
  Requires VK_ACCESS_TOKEN to be set in the environment.
  """

  @behaviour Botd.Adapters.VKApiAdapter

  @vk_api_url "https://api.vk.ru/method"
  @vk_api_version "5.199"

  @impl true
  def publish_post(token, owner_id, post_id) do
    params = %{
      owner_id: owner_id,
      post_id: post_id,
      access_token: token,
      v: @vk_api_version
    }

    call("wall.post", params)
  end

  @impl true
  def delete_post(token, owner_id, post_id) do
    params = %{
      owner_id: owner_id,
      post_id: post_id,
      access_token: token,
      v: @vk_api_version
    }

    call("wall.delete", params)
  end

  defp call(method, params) do
    url = "#{@vk_api_url}/#{method}"

    case HTTPoison.post(url, {:form, Enum.to_list(params)}) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"response" => response}} -> {:ok, response}
          {:ok, %{"error" => error}} -> {:error, error}
          {:error, reason} -> {:error, reason}
        end

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "HTTP #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
