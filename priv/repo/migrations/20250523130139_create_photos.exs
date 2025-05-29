defmodule Botd.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :url, :string, null: false
      add :size, :string, null: false
      add :person_id, references(:people, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:photos, [:person_id])
  end
end
