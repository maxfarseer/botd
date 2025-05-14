defmodule Botd.Repo.Migrations.AddTelegramUsernameToSuggestion do
  use Ecto.Migration

  def change do
    alter table(:suggestions) do
      add :telegram_username, :string
    end
  end
end
