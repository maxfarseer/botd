defmodule Botd.Repo.Migrations.AaddForeignKeyUserIdToActivityLogs do
  use Ecto.Migration

  def change do
    alter table(:activity_logs) do
      modify :user_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
