# LruCache

Discards the least recently used items first. This algorithm requires keeping track of what was used when, which is expensive if one wants to make sure the algorithm always discards the least recently used item. General implementations of this technique require keeping "age bits" for cache-lines and track the "Least Recently Used" cache-line based on age-bits. In such an implementation, every time a cache-line is used, the age of all other cache-lines changes. 
to know more about LRU cache see https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_recently_used_(LRU)

the simplest way to implement LRU is using LinkedList (to store Least recently Keys) and HashMap to Store Key-Value. implementing is challenge in Erlang/Elixir starts because they do not support LinkedList Structure. 

# TODO
## Impelementing LRU Cache
## Develop REST API
## Distributed System

