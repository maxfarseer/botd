defmodule Botd.Users.User do
  @moduledoc """
  The User schema and related functionality.

  This module defines the User schema for authentication with Pow,
  providing the structure for user accounts in the application.
  Users can log in, register, and perform actions that require authentication.

  Users have roles (admin, moderator, member) that control their permissions.
  """
  use Ecto.Schema
  use Pow.Ecto.Schema
  import Ecto.Changeset

  @roles [:admin, :moderator, :member]

  schema "users" do
    pow_user_fields()
    field :role, Ecto.Enum, values: @roles, default: :member

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> cast(attrs, [:role])
    |> validate_inclusion(:role, @roles)
  end

  @doc """
  Returns a list of all available roles.
  """
  def roles, do: @roles

  @doc """
  Checks if a user has the given role.
  """
  def has_role?(nil, _role), do: false
  def has_role?(user, role) when is_atom(role), do: user.role == role
  def has_role?(user, roles) when is_list(roles), do: user.role in roles

  @doc """
  Checks if the user is an admin.
  """
  def admin?(user), do: has_role?(user, :admin)

  @doc """
  Checks if the user is a moderator or admin.
  """
  def moderator_or_admin?(user), do: has_role?(user, [:moderator, :admin])
end
