defmodule MapBasedLruCacheLibTest do
  use ExUnit.Case
  doctest MapBasedLruCacheLib

  setup_all do
    {:ok, lru_cache: MapBasedLruCacheLib.new_instance(5), lru_cache_module: MapBasedLruCacheLib}
  end

  test "check consider capacity", state do
    lru_cache = state[:lru_cache]
    lru_cache_module = state[:lru_cache_module]
    lru_cap = lru_cache_module.capacity(lru_cache)

    lru_cache =
      1..(lru_cache_module.capacity(lru_cache) + 10)
      |> Enum.reduce(
        lru_cache,
        fn x, lru_cache ->
          lru_cache |> lru_cache_module.put(to_string(x), x)
        end
      )

    assert lru_cache_module.size(lru_cache) == lru_cache_module.capacity(lru_cache)

    {existance, _, _} = lru_cache_module.get(lru_cache, "1")
    assert existance == false

    {existance, _, _} = lru_cache_module.get(lru_cache, to_string(lru_cap + 10))
    assert existance == true

    {existance, _, _} = lru_cache_module.get(lru_cache, to_string(11))
    assert existance == true
  end
end
