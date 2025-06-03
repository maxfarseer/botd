defmodule Botd.Adapters.MockFileHandler do
  @moduledoc """
  Mock implementation of file handling operations for testing purposes.
  """
  @behaviour Botd.Adapters.FileHandlerAdapter

  @impl true
  def download_and_save_file(_url, _filename) do
    {:ok, "mocked_file_path"}
  end
end
