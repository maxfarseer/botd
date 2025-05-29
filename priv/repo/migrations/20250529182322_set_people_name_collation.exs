defmodule Botd.Repo.Migrations.SetPeopleNameCollation do
  use Ecto.Migration

  def up do
    execute("""
    ALTER TABLE people
      ALTER COLUMN name TYPE varchar COLLATE "und-x-icu",
      ALTER COLUMN nickname TYPE varchar COLLATE "und-x-icu",
      ALTER COLUMN place TYPE varchar COLLATE "und-x-icu",
      ALTER COLUMN description TYPE varchar COLLATE "und-x-icu";
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
