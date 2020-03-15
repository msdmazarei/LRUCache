defmodule WebApi.LruCache.GServer do
  use GenServer


  defstruct cache_instance: nil, module_name: nil
  @type state() :: %__MODULE__ {cache_instance: any, module_name: atom()}


  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(%{module_name: module_name, capacity: capacity}) do
    {:ok, %__MODULE__{
      cache_instance: module_name.new_instance(capacity),
      module_name: module_name
    }}
  end

  @impl true
  def handle_call({func_name, arguments}, _from, state=%__MODULE__{
    cache_instance: cache_instance, module_name: cache_module_name
  }) when func_name in [:size,:capacity] do
    result = apply(cache_module_name, func_name,[cache_instance|arguments])
    {:reply, result, state}
  end

  def handle_call({func_name, arguments}, _from, state=%__MODULE__{
    cache_instance: cache_instance, module_name: cache_module_name
  }) when func_name in [:delete,:put] do
    cache_instance = apply(cache_module_name, func_name,[cache_instance|arguments])
    state = %{state | cache_instance: cache_instance}
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get, arguments}, _from, state=%__MODULE__{
    cache_instance: cache_instance, module_name: cache_module_name
  })  do
    {existance, value, cache_instance} = apply(cache_module_name, :get ,[cache_instance|arguments])
    state = %{state | cache_instance: cache_instance}
    {:reply, {existance,value}, state}
  end


end
