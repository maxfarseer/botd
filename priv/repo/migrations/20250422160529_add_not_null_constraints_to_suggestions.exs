defmodule Botd.Repo.Migrations.AddNotNullConstraintsToSuggestions do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE suggestions ALTER COLUMN reviewed_by_id SET NOT NULL"
  end
end
