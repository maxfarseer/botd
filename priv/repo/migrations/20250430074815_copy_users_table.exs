defmodule Botd.Repo.Migrations.CopyUsersTable do
  use Ecto.Migration

  def change do
    create table(:old_users) do
      add :email, :string
      add :password_hash, :string
      add :inserted_at, :naive_datetime
      add :updated_at, :naive_datetime
      add :role, :string, default: "member"
    end

    execute "INSERT INTO old_users SELECT * FROM users"
  end
end
