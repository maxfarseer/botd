defmodule Botd.People.PersonTest do
  use Botd.DataCase, async: true
  alias Botd.People.Person

  describe "changeset/2" do
    test "validates required fields" do
      changeset = Person.changeset(%Person{}, %{})
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).death_date
    end

    test "validates death_date not in future" do
      future_date = Date.add(Date.utc_today(), 1)
      attrs = %{name: "Person", death_date: future_date}

      changeset = Person.changeset(%Person{}, attrs)
      assert "cannot be in the future" in errors_on(changeset).death_date
    end
  end

  test "valid changeset with all attributes" do
    attrs = %{
      name: "Test Person",
      nickname: "Tester",
      birth_date: ~D[1950-01-01],
      death_date: ~D[2020-01-01],
      place: "Test City",
      cause_of_death: "Test cause",
      description: "Test description"
    }

    changeset = Person.changeset(%Person{}, attrs)
    assert changeset.valid?
  end

  test "validates uniqueness of name and death_date" do
    # Erstelle eine Person in der Datenbank
    person_attrs = %{name: "Test Person", death_date: ~D[2020-01-01]}
    {:ok, _person} = %Person{} |> Person.changeset(person_attrs) |> Repo.insert()

    # Versuche, eine Person mit dem gleichen Namen und Todesdatum zu erstellen
    {:error, changeset} = %Person{} |> Person.changeset(person_attrs) |> Repo.insert()

    assert "A person with this name and death date already exists" in errors_on(changeset).name
  end
end
