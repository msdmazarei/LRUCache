defmodule LruCacheLib do
  @moduledoc """
  define behaviour for cache modules.
  We may have diffrenet implementation for LRUCache
  so it is better define a behaviour for all our LRUCache
  implementation.
  Each Cache should have at minimum three required functions:

    put(key, value)
    get(key)
    new_instance(capacity)

  every Cache impelentation has its own structure so we have no
  idea about the structure they want to use.


  """

  # new instance accept Capacity as input and will return LruCache Strcuture
  @callback new_instance(integer) :: any

  # put accept cachestructre, key , value as arguments and add new key to cache
  # and returns new CacheStructure
  @callback put(any, String.t(), any) :: any

  # delete accepts cache structure and key as input and remove key from cache
  @callback delete(any, String.t()) :: any

  # get accept cachestructre, key as input and retuns a tuple
  # to show it succeessed to find key and new cache structure
  @callback get(any, String.t()) :: {false, nil, any} | {true, any, any}

  # returns Cache actual size
  @callback size(any) :: integer

  # returns cache capacity
  @callback capacity(any) :: integer
end
