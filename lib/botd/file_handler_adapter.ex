defmodule Botd.FileHandlerAdapter do
  @moduledoc """
  Adapter for file handling operations.
  """

  @callback download_and_save_file(String.t(), String.t()) ::
              {:ok, String.t()} | {:error, String.t()}

  def download_and_save_file(url, filename) do
    impl().download_and_save_file(url, filename)
  end

  defp impl, do: Application.get_env(:botd, :file_handler, Botd.FileHandler)
end
