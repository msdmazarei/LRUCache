defmodule SimpleLruCacheLib do
  @moduledoc """
      this module is Simplest way to implement LRUCache

      to implement we need two data structure Array and HashMap
      we store last accessed key in array and key value in HashMap
      for any action(get/put) we should update Array.
      consider Array as below:

        [x1, x2, x3, ... , x100]

      x1 is recent accessed key and x100 is least recently accessed key
      Say if user want to get x50 key our array will change to below form:

        [x50, x1, x2, ... , x100]

      in a situation that our array size is same to capacity and user adds
      new item to our cache like x101 arrays will be:

        [x101,x50, x1, ... , x99]

      as you can see x100 is eliminated because it was least recently used item.

      you can check every function alorithm above of every function in this
      module. Order of this Algorithm is O(N/2) which N is actual size of cache
      because of filtering array on each event(get/put) to remove specific key
      and move it to head of array.

  """

  defstruct size: 0, capacity: 0, lru: [], hash_map: %{}

  @type simple_lru_cache() :: %__MODULE__{}

  @behaviour LruCacheLib

  @doc ~S"""
  initialize structure for specified `capacity` and returns structure.

  ## Examples

    iex> SimpleLruCacheLib.new_instance(5)
    %SimpleLruCacheLib{capacity: 5, hash_map: %{}, lru: [], size: 0}

    iex> SimpleLruCacheLib.new_instance(15)
    %SimpleLruCacheLib{capacity: 15, hash_map: %{}, lru: [], size: 0}


  """
  @spec new_instance(integer) :: simple_lru_cache()
  @impl true
  def new_instance(capacity) do
    %__MODULE__{capacity: capacity}
  end

  @doc ~S"""
    delete speciefied key from cache.

    Algorithm:
     if key exists in our HashMap
        remove it from lru array and hash map
        size = size - 1
        return updated structure
    else
        returns original passed cache structure
  """
  @spec delete(simple_lru_cache(), String.t()) :: simple_lru_cache()
  @impl true
  def delete(
        simple_lru_cache = %__MODULE__{
          size: size,
          lru: lru,
          hash_map: hash_map
        },
        key
      ) do
    if hash_map |> Map.has_key?(key) do
      %__MODULE__{
        simple_lru_cache
        | size: size - 1,
          lru: lru |> Enum.filter(fn x -> x != key end),
          hash_map: hash_map |> Map.delete(key)
      }
    else
      simple_lru_cache
    end
  end

  @doc ~S"""

  returns cache capacity

  ## Examples

    iex> SimpleLruCacheLib.new_instance(5) |> SimpleLruCacheLib.put("a","a") |> SimpleLruCacheLib.capacity()

    iex> SimpleLruCacheLib.new_instance(5) |> SimpleLruCacheLib.put("a","a")
    ...>  |> SimpleLruCacheLib.put("b","b")


  """
  @spec capacity(simple_lru_cache()) :: integer
  @impl true
  def capacity(%__MODULE__{capacity: capacity}) do
    capacity
  end

  @doc ~S"""
  returns  actual size of cache

  ## Examples
    iex> SimpleLruCacheLib.new_instance(5) |> SimpleLruCacheLib.put("a","a") |> SimpleLruCacheLib.size()
    1

    iex> SimpleLruCacheLib.new_instance(5)
    ...>  |> SimpleLruCacheLib.put("a","a")
    ...>  |> SimpleLruCacheLib.put("a","a")
    ...>  |> SimpleLruCacheLib.size()
    1


    iex> SimpleLruCacheLib.new_instance(5)
    ...>  |> SimpleLruCacheLib.put("a","a")
    ...>  |> SimpleLruCacheLib.put("b","b")
    ...>  |> SimpleLruCacheLib.size()
    2


  """
  @spec size(simple_lru_cache()) :: integer
  @impl true
  def size(%__MODULE__{size: cache_size}) do
    cache_size
  end

  @doc ~S"""
  search cache for key if successfully found it returns {true, value, new_cache_struct}
  else {false, nil, new_cache_struct}


  ## Algorithm
    if key in HashMap
      move requested key to head of lru array
      return {true, value, update cache by new lru}
    else
      return {false, nil, cache}

  ## Examples

      iex> {false, nil, _} = SimpleLruCacheLib.new_instance(5) |> SimpleLruCacheLib.get("a")

      iex> SimpleLruCacheLib.new_instance(5) |> SimpleLruCacheLib.put("a","a")
      ...>  |> SimpleLruCacheLib.put("b","b")
      ...>  |> SimpleLruCacheLib.get("a")
      {true, "a", %SimpleLruCacheLib{capacity: 5, hash_map: %{"a" => "a", "b" => "b" }, lru: ["a","b"], size: 2}}
  """
  @spec get(simple_lru_cache(), String.t()) :: {boolean, any, simple_lru_cache()}
  @impl true
  def get(
        simple_lru_cache = %__MODULE__{
          hash_map: hash_map
        },
        key
      ) do
    if hash_map |> Map.has_key?(key) do
      {true, hash_map |> Map.get(key), simple_lru_cache |> update_key_part(key)}
    else
      {false, nil, simple_lru_cache}
    end
  end

  @doc ~S"""
    update cache by provied key, value

    ## Algorithm
      if size < capacity:
        if key in HashMap:
          update lru array and move key to end of lru array
        else:
          add key,value to HashMap
          append key to lru array
      else:
        if key in HashMap:
          update lru array and move key to end of lru array
        else:
          delete first key in lru array
          add key, value to cache

    ## Examples
        iex> SimpleLruCacheLib.new_instance(5) |> SimpleLruCacheLib.put("a","a")
        %SimpleLruCacheLib{capacity: 5, hash_map: %{"a" => "a"}, lru: ["a"], size: 1}

        iex> SimpleLruCacheLib.new_instance(5) |> SimpleLruCacheLib.put("a","a") |> SimpleLruCacheLib.put("b","b")
        %SimpleLruCacheLib{capacity: 5, hash_map: %{"a" => "a", "b" => "b" }, lru: ["b","a"], size: 2}

        iex>  SimpleLruCacheLib.new_instance(5)
        ...>        |> SimpleLruCacheLib.put("a","a")
        ...>        |> SimpleLruCacheLib.put("b","b")
        ...>        |> SimpleLruCacheLib.put("a","a")
        %SimpleLruCacheLib{capacity: 5, hash_map: %{"a" => "a", "b" => "b" }, lru: ["a","b"], size: 2}

        iex> SimpleLruCacheLib.new_instance(5) |> SimpleLruCacheLib.put("a","a")
        ...> |> SimpleLruCacheLib.put("a","b")
        ...> |> SimpleLruCacheLib.get("a")
        ...> |> Tuple.to_list |> Enum.at(1)
        "b"

  """
  @spec put(simple_lru_cache(), String.t(), any) :: simple_lru_cache()
  @impl true
  def put(
        simple_lru_cache = %__MODULE__{
          hash_map: hash_map
        },
        key,
        value
      ) do
    if hash_map |> Map.has_key?(key) do
      simple_lru_cache = update_key_part(simple_lru_cache, key)

      %{
        simple_lru_cache
        | hash_map: hash_map |> Map.put(key, value)
      }
    else
      put_new_key(simple_lru_cache, key, value)
    end
  end

  @spec put_new_key(simple_lru_cache(), String.t(), any) :: simple_lru_cache()
  defp put_new_key(
         simple_lru_cache = %__MODULE__{
           hash_map: hash_map,
           lru: lru,
           size: size,
           capacity: capacity
         },
         key,
         value
       )
       when size < capacity do
    # for new key when our cache size is lesser than capacity simply
    # add it to HashMap and put key at head of lru array
    %{
      simple_lru_cache
      | hash_map: hash_map |> Map.put(key, value),
        size: size + 1,
        lru: [key | lru]
    }
  end

  defp put_new_key(
         simple_lru_cache = %__MODULE__{
           lru: lru
         },
         key,
         value
       ) do
    # when our cache is full and want to add new key
    # we should remove least recently used item(last item)
    # and add new key,value as well
    key_to_remove = lru |> List.last()
    simple_lru_cache |> delete(key_to_remove) |> put_new_key(key, value)
  end

  @spec update_key_part(simple_lru_cache(), String.t()) :: simple_lru_cache()
  defp update_key_part(
         simple_lru_cache = %__MODULE__{
           lru: lru
         },
         key
       ) do
    # move speciefied key to head of array

    new_lru = lru |> Enum.filter(fn x -> x != key end)
    %{simple_lru_cache | lru: [key | new_lru]}
  end
end
