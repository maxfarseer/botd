defmodule Botd.Repo.Migrations.CreateSuggestions do
  use Ecto.Migration

  def change do
    create table(:suggestions) do
      add :name, :string, null: false
      add :death_date, :date, null: false
      add :place, :string, null: false
      add :status, :string, null: false, default: "pending"
      add :notes, :text

      add :user_id, references(:users, on_delete: :restrict), null: false
      add :reviewed_by_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:suggestions, [:user_id])
    create index(:suggestions, [:status])
  end
end
