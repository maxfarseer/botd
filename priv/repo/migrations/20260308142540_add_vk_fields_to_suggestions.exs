defmodule Botd.Repo.Migrations.AddVkFieldsToSuggestions do
  use Ecto.Migration

  def change do
    alter table(:suggestions) do
      add :source, :string, default: "web", null: false
      add :vk_post_id, :integer
      add :vk_owner_id, :integer
    end
  end
end
