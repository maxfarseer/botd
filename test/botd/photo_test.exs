defmodule Botd.PhotoTest do
  use Botd.DataCase, async: true

  alias Botd.People
  alias Botd.People.Photo

  defp person_fixture do
    valid_person = %{
      name: "Person for photo",
      nickname: "P",
      birth_date: ~D[1900-01-01],
      death_date: ~D[2000-01-01],
      place: "City",
      cause_of_death: "none",
      description: "desc"
    }

    {:ok, person} = People.create_person(valid_person)
    person
  end

  test "create_photo/1 fails when size is missing" do
    person = person_fixture()

    attrs = %{"url" => "/uploads/x.jpg", "person_id" => person.id}
    assert {:error, %Ecto.Changeset{} = changeset} = People.create_photo(attrs)

    errors = errors_on(changeset)
    assert errors[:size] != nil
  end

  test "create_photo/1 succeeds when size is provided" do
    person = person_fixture()

    attrs = %{"url" => "/uploads/x.jpg", "person_id" => person.id, "size" => "original"}
    assert {:ok, %Photo{} = photo} = People.create_photo(attrs)
    assert photo.size == "original"
    assert photo.url == "/uploads/x.jpg"
    assert photo.person_id == person.id
  end
end
