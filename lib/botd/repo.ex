defmodule Botd.Repo do
  use Ecto.Repo,
    otp_app: :botd,
    adapter: Ecto.Adapters.Postgres
end
