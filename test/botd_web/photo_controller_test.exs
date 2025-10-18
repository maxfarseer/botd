defmodule BotdWeb.PhotoControllerTest do
  use BotdWeb.ConnCase, async: false

  alias Botd.People
  alias Botd.Repo
  alias Botd.People.Photo
  alias Botd.AccountsFixtures
  import Ecto.Query

  setup do
    {:ok, person} =
      People.create_person(%{
        name: "Upload Test Person",
        death_date: ~D[2020-01-01],
        place: "Test"
      })

    moderator = AccountsFixtures.user_fixture(%{email: "mod@example.com", role: :moderator})

    %{person: person, moderator: moderator}
  end

  test "uploads multiple files and creates photos", %{
    conn: conn,
    person: person,
    moderator: moderator
  } do
    conn = log_in_user(conn, moderator)

    tmp_dir = Path.join(System.tmp_dir!(), "botd_test_uploads")
    File.mkdir_p!(tmp_dir)

    # create two small temp files to simulate images
    file1 = Path.join(tmp_dir, "a.jpg")
    file2 = Path.join(tmp_dir, "b.jpg")
    File.write!(file1, "fakeimage1")
    File.write!(file2, "fakeimage2")

    upload1 = %Plug.Upload{path: file1, filename: "a.jpg", content_type: "image/jpeg"}
    upload2 = %Plug.Upload{path: file2, filename: "b.jpg", content_type: "image/jpeg"}

    conn =
      post(conn, "/protected/people/#{person.id}/photos", %{"photo" => [upload1, upload2]})

    assert redirected_to(conn) == "/people/#{person.id}"

    photos = Repo.all(from p in Photo, where: p.person_id == ^person.id)
    assert length(photos) == 2

    # verify files exist under priv/static/uploads
    Enum.each(photos, fn p ->
      # p.url is like "/uploads/filename.jpg"
      file_path = Path.join(:code.priv_dir(:botd), "static" <> p.url)
      assert File.exists?(file_path)
      File.rm_rf!(file_path)
    end)

    # cleanup temp dir
    File.rm_rf!(tmp_dir)
  end

  test "uploads single file and creates a photo", %{
    conn: conn,
    person: person,
    moderator: moderator
  } do
    conn = log_in_user(conn, moderator)

    tmp_dir = Path.join(System.tmp_dir!(), "botd_test_uploads_single")
    File.mkdir_p!(tmp_dir)

    file1 = Path.join(tmp_dir, "single.jpg")
    File.write!(file1, "fakeimage_single")

    upload = %Plug.Upload{path: file1, filename: "single.jpg", content_type: "image/jpeg"}

    conn = post(conn, "/protected/people/#{person.id}/photos", %{"photo" => upload})

    assert redirected_to(conn) == "/people/#{person.id}"

    photos = Repo.all(from p in Photo, where: p.person_id == ^person.id)
    assert length(photos) == 1

    Enum.each(photos, fn p ->
      file_path = Path.join(:code.priv_dir(:botd), "static" <> p.url)
      assert File.exists?(file_path)
      File.rm_rf!(file_path)
    end)

    File.rm_rf!(tmp_dir)
  end
end
