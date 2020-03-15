# LruCache

Discards the least recently used items first. This algorithm requires keeping track of what was used when, which is expensive if one wants to make sure the algorithm always discards the least recently used item. General implementations of this technique require keeping "age bits" for cache-lines and track the "Least Recently Used" cache-line based on age-bits. In such an implementation, every time a cache-line is used, the age of all other cache-lines changes. 
to know more about LRU cache see https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_recently_used_(LRU)

the simplest way to implement LRU is using LinkedList (to store Least recently Keys) and HashMap to Store Key-Value. implementing is challenge in Erlang/Elixir starts because they do not support LinkedList Structure. 

# Project Structure
we have two apps in this repo, 
* - lru_cache_lib wich contains two diffrent implementation of LRUCache based on diffrent concepts, algorithm in each module will describe how module works, 
* - web_api which suppots REST API

## web_api 
in web_api we have two folder "web_api" and "lru_cache". lru_cache prepare LruCacheLib functionality to use in web_api, it defines GenServer and some apis to work with GenServer and also WebApi.LruCache.Distributed modules make it distributable

to config web_api to use which algorithm and how many capacity our cache should have use config ( check dev.exs file to change `cache_impl_module_name` and `cache_capacity`)

# TODO: add logs in project!!!