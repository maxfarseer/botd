defmodule Botd.Repo.Migrations.RemoveEmailAndNameFromActivityLogs do
  use Ecto.Migration

  def change do
    alter table(:activity_logs) do
      remove :user_email
      remove :entity_name
    end
  end
end
