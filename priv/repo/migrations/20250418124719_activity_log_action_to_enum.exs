defmodule Botd.Repo.Migrations.ActivityLogActionToEnum do
  use Ecto.Migration

  def up do
    # make new enum
    execute """
    CREATE TYPE activity_logs_action_type AS ENUM ('create_person', 'create_person_via_suggestion', 'edit_person', 'remove_person', 'create_suggestion', 'edit_suggestion', 'remove_suggestion', 'approve_suggestion', 'reject_suggestion');
    """

    # temp column create
    alter table(:activity_logs) do
      add :action_new, :activity_logs_action_type
    end

    # Data from old column to new column
    execute """
    UPDATE activity_logs
    SET action_new = action::activity_logs_action_type
    """

    # 4. Old column remove, new column rename
    alter table(:activity_logs) do
      remove :action
    end

    rename table(:activity_logs), :action_new, to: :action
  end

  def down do
    alter table(:activity_logs) do
      add :action_old, :string
    end

    # Data from Enum to string
    execute """
    UPDATE activity_logs
    SET action_old = action::text
    """

    alter table(:activity_logs) do
      remove :action
    end

    rename table(:activity_logs), :action_old, to: :action

    # Enum type drop
    execute """
    DROP TYPE activity_logs_action_type;
    """
  end
end
