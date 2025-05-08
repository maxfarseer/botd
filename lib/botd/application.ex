defmodule Botd.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        BotdWeb.Telemetry,
        Botd.Repo,
        {DNSCluster, query: Application.get_env(:botd, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Botd.PubSub},
        # Start the Finch HTTP client for sending emails
        {Finch, name: Botd.Finch},
        # Start a worker by calling: Botd.Worker.start_link(arg)
        # {Botd.Worker, arg},

        # Start to serve requests, typically the last entry
        BotdWeb.Endpoint
      ] ++
        if Mix.env() != :test do
          [
            # Start telegram bot genserver
            {Botd.Bot,
             bot_key:
               System.get_env("TELEGRAM_BOT_TOKEN") || raise("TELEGRAM_BOT_TOKEN is not set")}
          ]
        else
          []
        end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Botd.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BotdWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
