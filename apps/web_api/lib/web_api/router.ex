defmodule WebApi.Router do
  use WebApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WebApi do
    pipe_through :api
  end
end
