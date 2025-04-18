defmodule Botd.Repo.Migrations.UpdateEntityTypeStringValuesInActivityLogs do
  use Ecto.Migration

  def up do
    execute """
    UPDATE activity_logs
    SET action = 'create_person'
    WHERE action = 'create';
    """

    execute """
    UPDATE activity_logs
    SET action = 'edit_person'
    WHERE action = 'edit';
    """

    execute """
    UPDATE activity_logs
    SET action = 'remove_person'
    WHERE action = 'remove';
    """
  end

  def down do
    execute """
    UPDATE activity_logs
    SET action = 'create'
    WHERE action = 'create_person';
    """

    execute """
    UPDATE activity_logs
    SET action = 'edit'
    WHERE action = 'edit_person';
    """

    execute """
    UPDATE activity_logs
    SET action = 'remove'
    WHERE action = 'remove_person';
    """
  end
end
