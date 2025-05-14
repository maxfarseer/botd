defmodule Botd.Repo.Migrations.AddPhotoUrlToPersonAndSuggestion do
  use Ecto.Migration

  def change do
    alter table(:suggestions) do
      add :photo_url, :string
    end

    alter table(:people) do
      add :photo_url, :string
    end
  end
end
