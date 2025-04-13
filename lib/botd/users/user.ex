defmodule Botd.Users.User do
  @moduledoc """
  The User schema and related functionality.

  This module defines the User schema for authentication with Pow,
  providing the structure for user accounts in the application.
  Users can log in, register, and perform actions that require authentication.
  """
  use Ecto.Schema
  use Pow.Ecto.Schema

  schema "users" do
    pow_user_fields()

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
  end
end
