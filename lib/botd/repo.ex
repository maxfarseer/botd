defmodule Botd.Repo do
  use Ecto.Repo,
    otp_app: :botd,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
