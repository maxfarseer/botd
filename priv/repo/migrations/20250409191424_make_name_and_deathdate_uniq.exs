defmodule Botd.Repo.Migrations.MakeNameAndDeathdateUniq do
  use Ecto.Migration

  def change do
    create unique_index(:people, [:name, :death_date], name: :people_name_death_date_index)
  end
end
