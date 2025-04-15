[![CircleCI](https://circleci.com/gh/maxfarseer/botd.svg?style=shield)](https://circleci.com/gh/maxfarseer/botd)

# Book of the dead

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

## Ecto update user to :admin

In the terminal `iex -S mix`

```
alias Botd.Repo
alias Botd.Users.User

# Find a user
user = Repo.get_by(User, email: "user@example.com")

# Change the role
{:ok, _updated_user} = user |> Ecto.Changeset.change(role: :admin) |> Repo.update()
```

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
