defmodule Botd.Repo.Migrations.RemoveNotNullConstraintForReviewedBy do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE suggestions ALTER COLUMN reviewed_by_id DROP NOT NULL"
  end
end
