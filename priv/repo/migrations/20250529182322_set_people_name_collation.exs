defmodule Botd.Repo.Migrations.SetPeopleNameCollation do
  use Ecto.Migration

  def up do
    execute("""
    ALTER TABLE people
      ALTER COLUMN name TYPE varchar COLLATE "ru_RU.UTF-8",
      ALTER COLUMN nickname TYPE varchar COLLATE "ru_RU.UTF-8",
      ALTER COLUMN place TYPE varchar COLLATE "ru_RU.UTF-8",
      ALTER COLUMN description TYPE varchar COLLATE "ru_RU.UTF-8";
    """)
  end

  def down do
    execute("""
    ALTER TABLE people
      ALTER COLUMN name TYPE varchar,
      ALTER COLUMN nickname TYPE varchar,
      ALTER COLUMN place TYPE varchar,
      ALTER COLUMN description TYPE varchar;
    """)
  end
end
