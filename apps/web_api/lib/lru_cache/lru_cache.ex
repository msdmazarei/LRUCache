defmodule WebApi.LruCache do
  @pid WebApi.LruCache.GServer

  @spec get(String.t()) :: {false, nil} | {true, any}
  def get(key) do
    GenServer.call(@pid, {:get, [key]})
  end

  @spec delete(String.t()) :: :ok
  def delete(key) do
    GenServer.call(@pid, {:delete, [key]})
  end

  @spec put(String.t(), any) :: :ok
  def put(key, value) do
    GenServer.call(@pid, {:put, [key, value]})
  end

  @spec size() :: integer
  def size() do
    GenServer.call(@pid, {:size, []})
  end

  @spec capacity() :: integer
  def capacity() do
    GenServer.call(@pid, {:capacity, []})
  end
end
