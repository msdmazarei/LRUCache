defmodule MapBasedLruCacheLibTest do
  use ExUnit.Case
  doctest MapBasedLruCacheLib

  setup_all do
    {:ok, lru_cache: MapBasedLruCacheLib.new_instance(5), lru_cache_module: MapBasedLruCacheLib}
  end


  test "check lru-cache works for an item", state do
    lrucache = state[:lru_cache]
    lru_cache_module = state[:lru_cache_module]
    lrucache = lrucache |> lru_cache_module.put("test_key", "test_value")
    assert lru_cache_module.size(lrucache) == 1
    {exists, value, _} = lrucache |> lru_cache_module.get("test_key")
    assert value == "test_value" and exists == true
  end

  test "check lru-cache consider capacity", state do
    lrucache = state[:lru_cache]
    lru_cache_module = state[:lru_cache_module]

    lrucache =
      1..(lrucache |> lru_cache_module.capacity())
      |> Enum.reduce(lrucache, fn x, lrucache ->
        lrucache |> lru_cache_module.put(to_string(x), to_string(x))
      end)

    assert lru_cache_module.size(lrucache) == lru_cache_module.capacity(lrucache)

    lrucache = lrucache |> lru_cache_module.put("11", "11")
    assert lru_cache_module.size(lrucache) == lru_cache_module.capacity(lrucache)

    # oldest item should not exists
    {false, nil, _} = lru_cache_module.get(lrucache, "1")
  end

  test "check lru-cache remove Last recent Used Item", state do
    lrucache = state[:lru_cache]
    lru_cache_module = state[:lru_cache_module]

    lrucache =
      1..(lrucache |> lru_cache_module.capacity())
      |> Enum.reduce(lrucache, fn x, lrucache ->
        lrucache |> lru_cache_module.put(to_string(x), to_string(x))
      end)

    assert lru_cache_module.size(lrucache) == lru_cache_module.capacity(lrucache)
    {_, _, lrucache} = lru_cache_module.get(lrucache, "1")
    # right now by accessing element "1", the oldest item is "2"
    # adding new item should remove "2"
    lrucache = lrucache |> lru_cache_module.put("11", "11")
    # oldest item should not exists
    {false, nil, _} = lru_cache_module.get(lrucache, "2")
    {true, "1", _} = lru_cache_module.get(lrucache, "1")
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
