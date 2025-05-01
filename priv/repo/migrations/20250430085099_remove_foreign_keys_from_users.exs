defmodule Botd.Repo.Migrations.RemoveForeignKeysFromUsers do
  use Ecto.Migration

  def change do
    alter table(:suggestions) do
      remove :reviewed_by_id
      remove :user_id
    end

    alter table(:activity_logs) do
      remove :user_id
    end
  end
end
