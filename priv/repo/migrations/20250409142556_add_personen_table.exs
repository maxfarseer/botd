defmodule Botd.Repo.Migrations.AddPersonenTable do
  use Ecto.Migration

  def change do
    create table(:persons) do
      add :name, :string, null: false
      add :nickname, :string
      add :birth_date, :date
      add :death_date, :date, null: false
      add :place, :string
      add :cause_of_death, :text
      add :description, :text

      timestamps()
    end

    create index(:persons, [:name])
  end
end
