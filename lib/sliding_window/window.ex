defmodule SlidingWindow.Window do
  defstruct [:queue, :aggregate]

  @doc false
  def init_window(empty_aggregate) do
    %__MODULE__{queue: Okasaki.Queue.new(), aggregate: empty_aggregate}
  end

  def add_item(window, {timestamp, item}, behaviour_implementation) do
    new_queue = Okasaki.Queue.insert(window.queue, {timestamp, item})
    new_aggregate = behaviour_implementation.add_item(window.aggregate, item)
    %{window | queue: new_queue, aggregate: new_aggregate}
  end

  def remove_stale_items(window, behaviour_implementation, time_threshold) do
    {stale_queue, still_fresh_queue} = Okasaki.Queue.take_while(window.queue, fn {timestamp, _item} -> Timex.compare(timestamp, time_threshold) == -1 end)
    new_aggregate = Enum.reduce(stale_queue, window.aggregate, fn {_timestamp, item}, aggregate ->
      behaviour_implementation.remove_item(aggregate, item)
    end)
    updated_struct = %__MODULE__{window | queue: still_fresh_queue, aggregate: new_aggregate}
    {stale_queue, updated_struct}
  end

  def get_aggregate(window) do
    window.aggregate
  end
end
