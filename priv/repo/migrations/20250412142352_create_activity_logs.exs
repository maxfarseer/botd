defmodule Botd.Repo.Migrations.CreateActivityLogs do
  use Ecto.Migration

  def change do
    create table(:activity_logs) do
      add :action, :string, null: false
      add :entity_type, :string, null: false
      add :entity_id, :integer, null: false
      add :entity_name, :string, null: false
      add :user_id, :integer
      add :user_email, :string

      timestamps()
    end

    create index(:activity_logs, [:entity_type, :entity_id])
    create index(:activity_logs, [:user_id])
  end
end
