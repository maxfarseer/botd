defmodule Botd.Repo.Migrations.MakeSuggestionPlaceNullable do
  use Ecto.Migration

  def change do
    alter table(:suggestions) do
      modify :place, :string, null: true
    end
  end
end
