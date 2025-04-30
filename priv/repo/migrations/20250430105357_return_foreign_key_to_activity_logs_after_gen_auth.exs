defmodule Botd.Repo.Migrations.ReturnForeignKeyToActivityLogsAfterGenAuth do
  use Ecto.Migration

  def change do
    alter table(:activity_logs) do
      add :user_id, references(:users, on_delete: :nilify_all)
    end

    create index(:activity_logs, [:user_id])
  end
end
