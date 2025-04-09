defmodule Botd.Repo.Migrations.RenamePersonsToPeople do
  use Ecto.Migration

  def up do
    rename table(:persons), to: table(:people)
  end

  def down do
    rename table(:people), to: table(:persons)
  end
end
