defmodule Botd.Seeds.MovieCharacters do
  @moduledoc """
  Seed script to populate the database with famous deceased movie characters.

  This script reads character data from expanded_characters.csv file
  and imports them into the database.
  """

  alias Botd.People
  alias Botd.ActivityLogs
  alias Botd.Repo
  alias Botd.Accounts.User
  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Reads the CSV file and inserts the characters into the database.
  """
  def seed do
    # Ensure the system user exists
    system_user = ensure_system_user()

    # Path to the CSV file
    file_path = Path.join(__DIR__, "expanded_characters.csv")

    # Check if CSV file exists
    unless File.exists?(file_path) do
      raise "CSV file not found at #{file_path}. Please ensure expanded_characters.csv exists."
    end

    # Count how many characters were added successfully
    {count, errors} =
      file_path
      |> File.read!()
      |> CSV.parse_string(skip_headers: true)
      |> Enum.reduce({0, 0}, fn person_data, {success, errors} ->
        case insert_person(person_data, system_user) do
          {:ok, _} -> {success + 1, errors}
          {:error, _} -> {success, errors + 1}
        end
      end)

    IO.puts("✓ Added #{count} movie characters to the database")

    if errors > 0 do
      IO.puts("⚠ #{errors} characters could not be added due to errors")
    end
  end

  defp ensure_system_user do
    # Check if the system user already exists
    case Repo.get_by(User, id: 0) do
      nil ->
        # Create the system user if it doesn't exist
        %User{id: 0, email: "system@bookofthedead.local", role: :moderator, hashed_password: "123"}
        |> Repo.insert!()

      user ->
        user
    end
  end

  defp insert_person([name, nickname, birth_date, death_date, place, cause_of_death, description], user) do
    # Parse dates
    parsed_birth_date = parse_date(birth_date)
    parsed_death_date = parse_date(death_date)

    # Create person attributes
    person_attrs = %{
      name: name,
      nickname: nickname,
      birth_date: parsed_birth_date,
      death_date: parsed_death_date,
      place: place,
      cause_of_death: cause_of_death,
      description: description
    }

    # Insert person, log activity, and return result
    case People.create_person(person_attrs) do
      {:ok, person} = result ->
        # Log the creation action
        ActivityLogs.log_person_action(:create_person, person, user)
        IO.puts("Added person: #{person.name} (with activity log)")
        result

      {:error, changeset} = error ->
        IO.puts("Error adding #{name}: #{inspect(changeset.errors)}")
        error
    end
  end

  defp parse_date(""), do: nil
  defp parse_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      {:error, reason} ->
        IO.puts("Warning: Could not parse date '#{date_string}': #{reason}")
        nil
    end
  end
end

# Run the seed function if this script is executed directly
if Code.ensure_loaded?(Botd.People) do
  # Check if NimbleCSV is available
  unless Code.ensure_loaded?(NimbleCSV) do
    IO.puts("Installing NimbleCSV dependency...")
    Mix.install([{:nimble_csv, "~> 1.1"}])
  end

  Botd.Seeds.MovieCharacters.seed()
else
  IO.puts("Error: Cannot load Botd.People. Make sure the application is compiled.")
end
