defmodule Noveo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Noveo.Repo,
      # Start the Telemetry supervisor
      NoveoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Noveo.PubSub},
      # Start the Endpoint (http/https)
      NoveoWeb.Endpoint,
      Noveo.Workers.EtsSeed,
      con_cache_child_spec(:jobs),
      con_cache_child_spec(:professions)
      # Start a worker by calling: Noveo.Worker.start_link(arg)
      # {Noveo.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Noveo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp con_cache_child_spec(name) do
    Supervisor.child_spec(
      {
        ConCache,
        [
          name: name,
          ttl_check_interval: false
        ]
      },
      id: {ConCache, name}
    )
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NoveoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
