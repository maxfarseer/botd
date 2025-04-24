defmodule Botd.PeopleTest do
  use Botd.DataCase, async: true

  alias Botd.People
  alias Botd.People.Person

  describe "people" do
    @valid_attrs %{
      name: "Test Person",
      nickname: "Tester",
      birth_date: ~D[1950-01-01],
      death_date: ~D[2020-01-01],
      place: "Test City",
      cause_of_death: "Test cause",
      description: "Test description"
    }
    @update_attrs %{
      name: "Updated Person",
      nickname: "Updated",
      birth_date: ~D[1951-02-02],
      death_date: ~D[2021-02-02],
      place: "Updated City",
      cause_of_death: "Updated cause",
      description: "Updated description"
    }
    @invalid_attrs %{name: nil, death_date: nil}

    def person_fixture(attrs \\ %{}) do
      {:ok, person} =
        attrs
        |> Enum.into(@valid_attrs)
        |> People.create_person()

      person
    end

    test "list_people/1 returns all people" do
      person = person_fixture()
      %{entries: entries} = People.list_people()
      assert entries == [person]
    end

    test "list_people/1 returns paginated people" do
      _people =
        for i <- 1..15 do
          attrs = %{@valid_attrs | name: "Person #{i}", nickname: "P#{i}"}
          {:ok, person} = People.create_person(attrs)
          person
        end

      # Test default pagination (page 1, default per_page)
      page1 = People.list_people()
      assert %{entries: entries, page_number: 1, total_pages: total_pages} = page1
      assert length(entries) <= 10
      assert total_pages > 1

      # Test custom page and per_page
      page2 = People.list_people(page: 2, per_page: 5)
      assert %{entries: entries2, page_number: 2, total_pages: total_pages2} = page2
      assert length(entries2) <= 5
      assert total_pages2 == 3

      # Make sure we get different results on different pages
      page1_small = People.list_people(page: 1, per_page: 5)
      page2_small = People.list_people(page: 2, per_page: 5)

      page1_ids = Enum.map(page1_small.entries, & &1.id)
      page2_ids = Enum.map(page2_small.entries, & &1.id)
      # No person should appear on both pages
      assert Enum.empty?(page1_ids -- (page1_ids -- page2_ids))

      # Test if sort order is preserved
      names_on_page = Enum.map(page1_small.entries, & &1.updated_at)
      sorted_names = Enum.sort(names_on_page)
      assert names_on_page == sorted_names
    end

    test "get_person!/1 returns the person with given id" do
      person = person_fixture()
      assert People.get_person!(person.id) == person
    end

    test "create_person/1 with valid data creates a person" do
      assert {:ok, %Person{} = person} = People.create_person(@valid_attrs)
      assert person.name == "Test Person"
      assert person.nickname == "Tester"
      assert person.birth_date == ~D[1950-01-01]
      assert person.death_date == ~D[2020-01-01]
      assert person.place == "Test City"
      assert person.cause_of_death == "Test cause"
      assert person.description == "Test description"
    end

    test "create_person/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = People.create_person(@invalid_attrs)
    end

    test "update_person/2 with valid data updates the person" do
      person = person_fixture()
      assert {:ok, %Person{} = updated} = People.update_person(person, @update_attrs)
      assert updated.name == "Updated Person"
      assert updated.nickname == "Updated"
      assert updated.birth_date == ~D[1951-02-02]
      assert updated.death_date == ~D[2021-02-02]
      assert updated.place == "Updated City"
      assert updated.cause_of_death == "Updated cause"
      assert updated.description == "Updated description"
    end

    test "update_person/2 with invalid data returns error changeset" do
      person = person_fixture()
      assert {:error, %Ecto.Changeset{}} = People.update_person(person, @invalid_attrs)
      assert person == People.get_person!(person.id)
    end

    test "delete_person/1 deletes the person" do
      person = person_fixture()
      assert {:ok, %Person{}} = People.delete_person(person)
      assert_raise Ecto.NoResultsError, fn -> People.get_person!(person.id) end
    end

    test "change_person/1 returns a person changeset" do
      person = person_fixture()
      assert %Ecto.Changeset{} = People.change_person(person)
    end
  end
end
