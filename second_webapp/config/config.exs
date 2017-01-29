# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :second_webapp,
  ecto_repos: [SecondWebapp.Repo]

# Configures the endpoint
config :second_webapp, SecondWebapp.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "05qN5XU1Rai/05dEVSuF4SbTzlzbYbSZO95iVF66KRqpZAGT/9kN3FpeLuh9IrZA",
  render_errors: [view: SecondWebapp.ErrorView, accepts: ~w(json)],
  pubsub: [name: SecondWebapp.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
