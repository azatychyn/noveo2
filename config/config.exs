# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :noveo,
  ecto_repos: [Noveo.Repo]

# Configures the endpoint
config :noveo, NoveoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SpwDtWfR5btz8af1HW8PgPs0OGTUn8Jr05Q7rHpQo/NfNV5UwH3wotNgzvGjV36a",
  render_errors: [view: NoveoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Noveo.PubSub,
  live_view: [signing_salt: "2mQ5H6tz"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
