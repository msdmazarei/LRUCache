defmodule WebApi.Router do
  use WebApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WebApi do
    pipe_through :api
    get "/cache/:key", LruCacheController, :get
    post "/cache/:key", LruCacheController, :create
    delete "/cache/:key", LruCacheController, :delete
  end
end
