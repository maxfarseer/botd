defmodule Botd.Repo.Migrations.AddPhotosToSuggestions do
  use Ecto.Migration

  def change do
    alter table(:suggestions) do
      add :photos, {:array, :string}
    end
  end
end
