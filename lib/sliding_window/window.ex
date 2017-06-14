defmodule SlidingWindow.Window do
  defstruct [:queue, :aggregate]

  @doc false
  def init_window(empty_aggregate) do
    %__MODULE__{queue: Okasaki.Queue.new(), aggregate: empty_aggregate}
  end

  def add_item(window_struct, item, behaviour_implementation) do
    timestamp = behaviour_implementation.extract_timestamp(item)
    new_queue = Okasaki.Queue.insert(window_struct.queue, {timestamp, item})
    new_aggregate = behaviour_implementation.add_item(window_struct.aggregate, item)
    %{window_struct | queue: new_queue, aggregate: new_aggregate}
  end

  def remove_stale_items(window_struct, behaviour_implementation, time_now) do
    {stale_queue, still_fresh_queue} = Okasaki.Queue.take_while(window_struct.queue, fn {timestamp, item} -> Timex.compare(timestamp,time_now) == :lt end)
    new_aggregate = Enum.reduce(stale_queue, window_struct.aggregate, fn aggregate, {timestamp, item} ->
      behaviour_implementation.remove_item(aggregate, item)
    end)
    updated_struct = %{window_struct | queue: still_fresh_queue, aggregate: new_aggregate}
    {stale_queue, updated_struct}
  end
end
