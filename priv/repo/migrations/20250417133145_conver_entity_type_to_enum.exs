defmodule Botd.Repo.Migrations.ConvertEntityTypeToEnum do
  use Ecto.Migration

  def up do
    # 1. Create enym type
    execute("""
    CREATE TYPE activity_logs_entity_type AS ENUM ('person', 'suggestion');
    """)

    # 2. temp enum column
    alter table(:activity_logs) do
      add :entity_type_tmp, :activity_logs_entity_type
    end

    # 3. copy data from string to enum
    execute("""
    UPDATE activity_logs
    SET entity_type_tmp = entity_type::activity_logs_entity_type
    """)

    # 4. old table remove
    alter table(:activity_logs) do
      remove :entity_type
    end

    # 5. new enum column rename
    rename table(:activity_logs), :entity_type_tmp, to: :entity_type
  end

  def down do
    alter table(:activity_logs) do
      add :entity_type_tmp, :string
    end

    execute("""
    UPDATE activity_logs
    SET entity_type_tmp = entity_type::text
    """)

    alter table(:activity_logs) do
      remove :entity_type
    end

    rename table(:activity_logs), :entity_type, to: :entity_type_tmp

    execute("DROP TYPE activity_logs_entity_type;")
  end
end
