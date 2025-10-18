defmodule BotdWeb.PhotoController do
  use BotdWeb, :controller

  alias Botd.People
  alias Botd.Repo
  alias Botd.People.Photo

  def create(conn, %{"id" => person_id, "photo" => %Plug.Upload{} = upload}) do
    # Save file to priv/static/uploads
    upload_dir = Path.join(:code.priv_dir(:botd), "static/uploads")
    File.mkdir_p!(upload_dir)

    filename = "person_#{person_id}_#{:os.system_time(:millisecond)}_#{upload.filename}"
    dest = Path.join(upload_dir, filename)

    case File.cp(upload.path, dest) do
      :ok ->
        url = "/uploads/#{filename}"

        attrs = %{"url" => url, "person_id" => String.to_integer(person_id)}

        case People.create_photo(attrs) do
          {:ok, _photo} ->
            conn
            |> put_flash(:info, "Photo uploaded successfully")
            |> redirect(to: ~p"/people/#{person_id}")

          {:error, changeset} ->
            conn
            |> put_flash(:error, BotdWeb.ControllerHelpers.inspect_errors(changeset))
            |> redirect(to: ~p"/people/#{person_id}")
        end

      {:error, reason} ->
        conn
        |> put_flash(:error, "Failed to save uploaded file: #{inspect(reason)}")
        |> redirect(to: ~p"/people/#{person_id}")
    end
  end

  def create(conn, %{"id" => person_id}) do
    conn
    |> put_flash(:error, "No file uploaded")
    |> redirect(to: ~p"/people/#{person_id}")
  end
end
