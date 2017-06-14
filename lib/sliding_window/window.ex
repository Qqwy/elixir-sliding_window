defmodule SlidingWindow.Window do
  defstruct [:queue, :aggregate]

  @doc false
  def init_window(empty_aggregate) do
    %__MODULE__{queue: EQueue.new(), aggregate: empty_aggregate}
  end

  def add_item(window_struct, item, behaviour_implementation) do
    new_queue = EQueue.cons(window_struct.queue, item)
    new_aggregate = behaviour_implementation.add_item(window_struct.aggregate, item)
    %{window_struct | queue: new_queue, aggregate: new_aggregate}
  end

  def remove_stale_items(window_struct, behaviour_implementation, time_now) do
    # new_queue = :queue.cons(window_struct.queue, item)
    # new_aggregate = behaviour_implementation.add_item(window_struct.aggregate, item)
    # %{window_struct | queue: new_queue, aggregate: new_aggregate}
  end

end
