defmodule WebApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    cache_config = Application.get_env(:web_api, WebApi.LruCache.GServer)

    children = [
      # Start the endpoint when the application starts
      WebApi.Endpoint,
      {WebApi.LruCache.GServer.Sup,
       %{
         module_name: cache_config[:cache_impl_module_name],
         capacity: cache_config[:cache_capacity]
       }}

      # Starts a worker by calling: WebApi.Worker.start_link(arg)
      # {WebApi.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WebApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WebApi.Endpoint.config_change(changed, removed)
    :ok
  end
end
