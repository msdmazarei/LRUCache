defmodule WebApi.LruCache do
  @pid WebApi.LruCache.GServer

  def get(key) do
    GenServer.call(@pid, {:get, [key]})
  end

  def delete(key) do
    GenServer.call(@pid, {:delete, [key]})
  end

  def put(key, value) do
    GenServer.call(@pid, {:put,[key, value]})
  end

  def size() do
    GenServer.call(@pid, {:size,[]})
  end

  def capacity() do
    GenServer.call(@pid, {:capacity,[]})
  end

end
