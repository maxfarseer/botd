defmodule Botd.Adapters.LocalFileHandler do
  @moduledoc """
  Handles file downloads and storage.
  """
  @behaviour Botd.Adapters.FileHandlerAdapter

  @impl true
  def download_and_save_file(url, filename) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        upload_dir = Path.join(:code.priv_dir(:botd), "static/uploads")
        File.mkdir_p!(upload_dir)

        file_path = Path.join(upload_dir, filename)

        case File.write(file_path, body) do
          :ok ->
            {:ok, "/uploads/#{filename}"}

          {:error, reason} ->
            {:error, reason}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to download file. Status code: #{status_code}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
