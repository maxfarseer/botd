defmodule Botd.Repo.Migrations.AddNotNullConstraintsToActivityLogs do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE activity_logs ALTER COLUMN action SET NOT NULL"
    execute "ALTER TABLE activity_logs ALTER COLUMN entity_id SET NOT NULL"
    execute "ALTER TABLE activity_logs ALTER COLUMN entity_type SET NOT NULL"
    execute "ALTER TABLE activity_logs ALTER COLUMN user_id SET NOT NULL"
  end
end
