defmodule WebApi.LruCache.Distributed do
  use Bitwise

  @remote_module WebApi.LruCache

  def choose_node_by_key(key) do
    n =
      :crypto.hash(:md5, key)
      |> :binary.bin_to_list()
      |> Enum.reduce(fn x, acc -> rem(acc <<< (8 + x), 123_456_789) end)

    nodes = [:erlang.node() | :erlang.nodes()] |> Enum.sort()
    selected_node = rem(n, length(nodes))
    nodes |> Enum.at(selected_node)
  end

  def get(key) do
    :rpc.call(choose_node_by_key(key), @remote_module, :get, [key])
  end

  def delete(key) do
    :rpc.call(choose_node_by_key(key), @remote_module, :delete, [key])
  end

  def put(key, value) do
    :rpc.call(choose_node_by_key(key), @remote_module, :put, [key, value])
  end
end
