defmodule Botd.Repo.Migrations.ReturnForeignKeyToSuggestionAfterGenAuth do
  use Ecto.Migration

  def change do
    alter table(:suggestions) do
      add :user_id, references(:users, on_delete: :nilify_all)
      add :reviewed_by_id, references(:users, on_delete: :nilify_all)
    end

    create index(:suggestions, [:user_id])
  end
end
