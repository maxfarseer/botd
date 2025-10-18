defmodule BotdWeb.PhotoController do
  use BotdWeb, :controller

  alias Botd.People

  def create(conn, %{"id" => person_id, "photo" => uploads}) when is_list(uploads) do
    upload_dir = Path.join(:code.priv_dir(:botd), "static/uploads")
    File.mkdir_p!(upload_dir)

    person_id_int = String.to_integer(person_id)

    results =
      Enum.map(uploads, fn %Plug.Upload{} = upload ->
        filename = "person_#{person_id}_#{:os.system_time(:millisecond)}_#{upload.filename}"
        dest = Path.join(upload_dir, filename)

        case File.cp(upload.path, dest) do
          :ok ->
            url = "/uploads/#{filename}"
            attrs = %{"url" => url, "person_id" => person_id_int, "size" => "original"}
            People.create_photo(attrs)

          {:error, reason} ->
            {:error, "Failed to save file: #{inspect(reason)}"}
        end
      end)

    {oks, errs} = Enum.split_with(results, fn r -> match?({:ok, _}, r) end)

    if errs == [] do
      conn
      |> put_flash(:info, "#{length(oks)} photos uploaded successfully")
      |> redirect(to: ~p"/people/#{person_id}")
    else
      first_err = List.first(errs)

      conn
      |> put_flash(:error, "Some files failed to upload: #{inspect(first_err)}")
      |> redirect(to: ~p"/people/#{person_id}")
    end
  end

  def create(conn, %{"id" => person_id, "photo" => %Plug.Upload{} = upload}) do
    # backward-compatible single upload
    create(conn, %{"id" => person_id, "photo" => [upload]})
  end

  def create(conn, %{"id" => person_id}) do
    conn
    |> put_flash(:error, "No file uploaded")
    |> redirect(to: ~p"/people/#{person_id}")
  end
end
