# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :web_api,
  ecto_repos: [WebApi.Repo],
  generators: [context_app: false]

# Configures the endpoint
config :web_api, WebApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "clwT8BZCGeTZX00wya76lKnmEfLP2o3kq4ROguivJ+4/etqYP9v99N/Fp/LJ21yA",
  render_errors: [view: WebApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: WebApi.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "2QV8MiRG"]

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
