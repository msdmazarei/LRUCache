defmodule MapBasedLruCacheLib do
  @moduledoc """
  in simplest mode like SimpleLruCacheLib we used array
  to store keys which used by cache, and the problem
  was this method does not provide good search, because
  in the time we want change recently updated key we should
  whole of array to find target key and remove it and move it
  to head of array.
  Map provides better algorithm to searching and adding and removing
  something like O(log N).

  ## Breif Algorithm
  we can consider Map keys like befor array index
  and Map Values as key. see below:

  [k1, k2, k3, ... , k100]  === %{ 1 => k1, 2 => k2, 3 => k3, ... 100 => k100}

  this seems good but there is a problem, consider we used k3 and want change
  priority the final map should be something like:

    %{ 1 => k3, 2 => k1, 3 => k2, ... 100 => k100}

  this means all keys lesser than k3 key should be updated to k+1.
  to avoid this problem we can order descending, that means
  item with biggest value is most recently used one,
  so our map will be something like:

    %{ 1 => k100, 2 => k99, 3 => k98, ... 100 => k1}

  so by accessing to k3 (by get/put) we will have

   (before access):  %{ 1 => k100, ..., 98=>k3, 99=>k2, 100 => k1}
   (after access) :  %{ 1 => k100, ..., 99=>k2, 100 => k1, 101 => k3}

  ok, so a challenge:
  How you delete item by key from this map?
  consider we want to delete k50, how it is possible?
  simply we can have reverse map to this map.

  """

  defstruct size: 0,
            capacity: 0,
            access_counter: 0,
            hash_map: %{},
            counter_key_map: %{},
            key_counter_map: %{}

  @type map_based_lru_cache() :: %__MODULE__{
          size: integer,
          capacity: integer,
          access_counter: integer,
          hash_map: map(),
          counter_key_map: map(),
          key_counter_map: map()
        }

  @behaviour LruCacheLib

  @doc ~S"""

  returns new struct with passed capacity

  ## Examples
        iex> MapBasedLruCacheLib.new_instance(10)
        %MapBasedLruCacheLib{access_counter: 0,capacity: 10,counter_key_map: %{},hash_map: %{},key_counter_map: %{},size: 0}
  """
  @spec new_instance(integer) :: map_based_lru_cache()
  @impl true
  def new_instance(capacity)
      when is_integer(capacity) and capacity > 0 do
    %__MODULE__{capacity: capacity}
  end

  @doc ~S"""
    update cache by provied key, value

    ## Algorithm
      if size < capacity:
        if key in HashMap:
          inc access_counter
          update key_counter_map and set new access counter
          delete old counter value from counter_key_map
          add new counter value to counter_key_map
          update hashmap with new value
        else:
          inc access_counter
          update key_counter_map, counter_key_map with access_counter, key
          add key,value to HashMap
      else:
        if key in HashMap:
           inc access_counter
           update key_counter_map and set new access counter
           delete old counter value from counter_key_map
           add new counter value to counter_key_map
           update hashmap with new value
        else:
          get keys of counter_key_map as list and pick first key from list

          delete selected counter and passed key from key_counter_map, counter_key_map and hash_map
          add key, value to cache

    ## Examples
        iex> MapBasedLruCacheLib.new_instance(5) |> MapBasedLruCacheLib.put("a","a")
        %MapBasedLruCacheLib{access_counter: 1,capacity: 5,counter_key_map: %{1 => "a"},hash_map: %{"a" => "a"},key_counter_map: %{"a" => 1},size: 1}

        iex> MapBasedLruCacheLib.new_instance(5) |> MapBasedLruCacheLib.put("a","a") |> MapBasedLruCacheLib.put("b","b")
        %MapBasedLruCacheLib{access_counter: 2,capacity: 5,counter_key_map: %{1 => "a", 2 => "b"},hash_map: %{"a" => "a", "b" => "b"},key_counter_map: %{"a" => 1, "b" => 2},size: 2}

        iex>  MapBasedLruCacheLib.new_instance(5)
        ...>        |> MapBasedLruCacheLib.put("a","a")
        ...>        |> MapBasedLruCacheLib.put("b","b")
        ...>        |> MapBasedLruCacheLib.put("a","a")
        %MapBasedLruCacheLib{access_counter: 3,capacity: 5,counter_key_map: %{2 => "b", 3 => "a"},hash_map: %{"a" => "a", "b" => "b"},key_counter_map: %{"a" => 3, "b" => 2},size: 2}


        iex> MapBasedLruCacheLib.new_instance(5) |> MapBasedLruCacheLib.put("a","a")
        ...> |> MapBasedLruCacheLib.put("a","b")
        ...> |> MapBasedLruCacheLib.get("a")
        ...> |> Tuple.to_list |> Enum.at(1)
        "b"

  """
  @spec put(map_based_lru_cache(), String.t(), any) :: map_based_lru_cache()
  @impl true

  def put(
        lru_cache = %__MODULE__{
          hash_map: hash_map
        },
        key,
        value
      ) do
    if hash_map |> Map.has_key?(key) do
      lru_cache = lru_cache |> update_counter_parts(key)

      %{
        lru_cache
        | hash_map: hash_map |> Map.put(key, value)
      }
    else
      put_new_key(lru_cache, key, value)
    end
  end

  @doc ~S"""
    delete speciefied key from cache.

    Algorithm:
     if key exists in our HashMap
        find counter from key_counter_map
        delete items from key_counter_map and counter_key_map and hash_map
        size = size - 1
        return updated structure
    else
        returns original passed cache structure

    ## Examples
      iex> MapBasedLruCacheLib.new_instance(10)|>MapBasedLruCacheLib.put("a","a")|>MapBasedLruCacheLib.delete("a")|>MapBasedLruCacheLib.size
      0
  """
  @spec delete(map_based_lru_cache(), String.t()) :: map_based_lru_cache()
  @impl true
  def delete(
        lru_cache = %__MODULE__{
          size: size,
          hash_map: hash_map,
          key_counter_map: key_counter_map,
          counter_key_map: counter_key_map
        },
        key
      ) do
    if key_counter_map |> Map.has_key?(key) do
      counter_key_to_del = key_counter_map |> Map.get(key)

      %{
        lru_cache
        | size: size - 1,
          key_counter_map: key_counter_map |> Map.delete(key),
          counter_key_map: counter_key_map |> Map.delete(counter_key_to_del),
          hash_map: hash_map |> Map.delete(key)
      }
    else
      lru_cache
    end
  end

  @doc ~S"""
  search in cache for specified key and if successfully found
  item returns {true, value, new_cache_struct} else
    returns {false, nil, new_cache_struct}

    ## Algorithm:
      if key in hash_map:
        get counter from key_counter_map by key
        update key_counter_map and counter_map_key and access_counter
        return {true, value, updated_struct}
      else
        return {false, nil, struct}

    ## Examples
        iex> MapBasedLruCacheLib.new_instance(5) |> MapBasedLruCacheLib.put("a","a")
        ...> |> MapBasedLruCacheLib.get("a")|> Tuple.to_list |> Enum.at(1)
        "a"

        iex> MapBasedLruCacheLib.new_instance(5) |> MapBasedLruCacheLib.put("a","a")
        ...> |> MapBasedLruCacheLib.put("a","b") |> MapBasedLruCacheLib.get("a")
        ...> |> Tuple.to_list |> Enum.at(1)
        "b"
  """

  @spec get(map_based_lru_cache(), String.t()) ::
          {false, nil, map_based_lru_cache()} | {true, any, map_based_lru_cache()}
  @impl true
  def get(
        lru_cache = %__MODULE__{
          hash_map: hash_map
        },
        key
      ) do
    if hash_map |> Map.has_key?(key) do
      {true, hash_map |> Map.get(key), lru_cache |> update_counter_parts(key)}
    else
      {false, nil, lru_cache}
    end
  end

  @doc ~S"""
  returns cache actual size

  ## Examples

    iex> MapBasedLruCacheLib.new_instance(10) |> MapBasedLruCacheLib.size()
    0

    iex> MapBasedLruCacheLib.new_instance(10) |> MapBasedLruCacheLib.put("a","a") |> MapBasedLruCacheLib.size
    1
  """
  @spec size(map_based_lru_cache()) :: integer
  @impl true
  def size( %__MODULE__{size: size}) do
    size
  end

  @doc ~S"""
  returns cache capacity

  ## Examples
    iex> MapBasedLruCacheLib.new_instance(5) |> MapBasedLruCacheLib.capacity
    5

    iex> MapBasedLruCacheLib.new_instance(10) |> MapBasedLruCacheLib.capacity
    10
  """
  @spec capacity(map_based_lru_cache()) :: integer
  @impl true
  def capacity(
          %__MODULE__{
          capacity: capacity
        }
      ) do
    capacity
  end

  defp put_new_key(
         lru_cache = %__MODULE__{
           size: size,
           capacity: capacity,
           hash_map: hash_map
         },
         key,
         value
       )
       when size < capacity do
    lru_cache = lru_cache |> update_counter_parts(key)

    size =
      if hash_map |> Map.has_key?(key) do
        size
      else
        size + 1
      end

    %{
      lru_cache
      | size: size,
        hash_map: hash_map |> Map.put(key, value)
    }
  end

  defp put_new_key(
         lru_cache = %__MODULE__{
           size: size,
           capacity: capacity,
           counter_key_map: counter_key_map
         },
         key,
         value
       )
       when size == capacity do
    oldest_counter_in_cache = counter_key_map |> Map.keys() |> hd
    oldest_key_in_cache = counter_key_map |> Map.get(oldest_counter_in_cache)
    lru_cache |> delete(oldest_key_in_cache) |> put(key, value)
  end

  @spec update_counter_parts(map_based_lru_cache(), String.t()) :: map_based_lru_cache()
  defp update_counter_parts(
         lru_cache = %__MODULE__{
           access_counter: access_counter,
           counter_key_map: counter_key_map,
           key_counter_map: key_counter_map
         },
         key
       ) do
    counter_key_map =
      if key_counter_map |> Map.has_key?(key) do
        old_counter = key_counter_map |> Map.get(key)
        counter_key_map |> Map.delete(old_counter)
      else
        counter_key_map
      end

    %{
      lru_cache
      | access_counter: access_counter + 1,
        counter_key_map: counter_key_map |> Map.put(access_counter + 1, key),
        key_counter_map: key_counter_map |> Map.put(key, access_counter + 1)
    }
  end
end
