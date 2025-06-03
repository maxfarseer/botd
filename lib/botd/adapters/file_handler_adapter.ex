defmodule Botd.Adapters.FileHandlerAdapter do
  @moduledoc """
  Adapter for file handling operations.
  """
  @behaviour Botd.Adapters.FileHandlerAdapter

  @callback download_and_save_file(String.t(), String.t()) ::
              {:ok, String.t()} | {:error, String.t()}

  def download_and_save_file(url, filename) do
    impl().download_and_save_file(url, filename)
  end

  defp impl, do: Application.get_env(:botd, :file_handler, Botd.Adapters.LocalFileHandler)
end
