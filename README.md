[![CircleCI](https://circleci.com/gh/maxfarseer/botd.svg?style=shield)](https://circleci.com/gh/maxfarseer/botd)

# Book of the dead

![Screenshot 2025-04-25 at 11 17 47](https://github.com/user-attachments/assets/89ef6fde-fd9b-4904-994a-e14c7eede710)

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## CSV data import

Imports dead characters

```
mix run priv/repo/seeds/movie_characters.exs
```

## When it does not work, but it should

```
mix clean
mix compile
```

## Ecto

### How to run migrations?

```
mix ecto.migrate
```

### Rollback one migration

```
mix ecto.rollback
```

or with -n option for many

### How to update user to :admin?

In the terminal `iex -S mix`

```
alias Botd.Repo
alias Botd.Users.User

# Find a user
user = Repo.get_by(User, email: "user@example.com")

# Change the role
{:ok, _updated_user} = user |> Ecto.Changeset.change(role: :admin) |> Repo.update()
```

## PostgreSQL

### Commands

```
\dt                             # check tables
\d table_name                   # check columns
\dT+ activity_logs_entity_type  # check enum values
```

### Backup and restore local database

#### Connect to the database

If the database name is `botd_dev` and username is `postgres`

```
psql -d botd_dev
```

#### How to Backup

```
pg_dump -U postgres -h localhost -p 5432 botd_dev > backup.sql

```

#### How to restore

```
dropdb -U postgres botd_dev
createdb -U postgres botd_dev
psql -U postgres -d botd_dev < backup.sql
```

## Elixir highlights

### With operator

[Documentation](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#with/1)

Helps you to decrease case -> case -> ... nesting.

Example from app:

Before:

```elixir
def create(conn, %{"person" => person_params}) do
  case People.create_person(person_params) do
    {:ok, person} ->
      user = conn.assigns[:current_user]

      case ActivityLogs.log_person_action(:create, person, user) do
        {:ok, log} ->
          conn
          |> put_flash(:info, "Person created successfully.")
          |> redirect(to: ~p"/people/#{person}")

        {:error, reason} ->
          # raise an error
          IO.inspect(reason, label: "Error logging person creation")
      end

    {:error, %Ecto.Changeset{} = changeset} ->
      render(conn, :new, changeset: changeset)
  end
end
```

After:

```elixir
def create(conn, %{"person" => person_params}) do
  user = conn.assigns[:current_user]

  with {:ok, person} <- People.create_person(person_params),
        {:ok, _log} <- ActivityLogs.log_person_action(:create, person, user) do
    # Success path
    conn
    |> put_flash(:info, "Person created successfully.")
    |> redirect(to: ~p"/people/#{person}")
  else
    # Error paths
    {:error, %Ecto.Changeset{} = changeset} ->
      render(conn, :new, changeset: changeset)

    {:error, log_error} ->
      conn
      |> put_flash(:error, "Person was created but logging failed.")
      |> render(:new, changeset: People.change_person(%Person{}))
  end
end
```

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
