defmodule WebApi.LruCacheController do
  use WebApi, :controller
  import Phoenix.Controller

  @lru_cache_module WebApi.LruCache

  @doc ~S"""
endpoints for reteriving key from cache
example usage:
curl -v http://localhost:4000/api/cache/a
  """
  def get(conn, params) do
    case @lru_cache_module.get(params["key"]) do
      {false,nil} -> conn|> put_status(404) |>json(%{})
      {true, value}-> conn|> put_status(200)|>json(value)
    end
  end

  @doc ~S"""
  endpoint to create new item in cache
  sample:
  curl -XPOST -v http://localhost:4000/api/cache/a -H'Content-Type: application/json' --data '{"e":"f"}'
  """
  def create(conn, params) do
    key = params["key"]
    value = params |> Map.delete("key")
    @lru_cache_module.put(key, value)
    conn |> put_status(200) |> json(value)
  end

  @doc ~S"""
  delete key from cache

  sample:
  curl -v http://localhost:4000/api/cache/a
  """
  def delete(conn, params) do
    key = params["key"]
    @lru_cache_module.delete(key)
    conn |> put_status(200)|>json(%{})
  end
end
