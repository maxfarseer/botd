defmodule BotdWeb.UploadController do
  use BotdWeb, :controller

  def show(conn, %{"filename" => filename}) do
    file_path = Path.join(:code.priv_dir(:botd), "static/uploads/#{filename}")

    if File.exists?(file_path) do
      conn
      |> put_resp_content_type(MIME.from_path(file_path) || "application/octet-stream")
      |> send_file(200, file_path)
    else
      conn
      |> put_status(:not_found)
      |> text("File not found")
    end
  end
end
