defmodule Botd.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Botd.Accounts` context.
  """

  alias Botd.Accounts.User
  @roles User.roles()

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_role(role) when role in @roles do
    role
  end

  @doc """
  Returns a `member` user role if the role is nil.
  This function was designed to use in tests, because after phoenix gen.auth we have many tests which do not have any clue about the role. Update tests also a variant, but here I made a safe default for a time being.
  """
  def valid_user_role(role) when is_nil(role) do
    :member
  end

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      role: valid_user_role(attrs[:role])
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Botd.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
