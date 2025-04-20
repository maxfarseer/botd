defmodule BotdWeb.ControllerHelpers do
  @moduledoc """
  Helper functions shared across controllers.
  """

  @doc """
  Converts a changeset's errors to a human-readable string.
  """
  def inspect_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map(fn {field, errors} ->
      "#{field} #{Enum.join(errors, ", ")}"
    end)
  end
end
