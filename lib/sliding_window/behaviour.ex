defmodule SlidingWindow.Behaviour do
  @type aggregate_type :: any
  @type item_type :: any

  @callback empty_aggregate() :: aggregate_type
  @callback add_item(aggregate_type, item_type) :: aggregate_type
  @callback remove_item(aggregate_type, item_type) :: aggregate_type
  @callback extract_timestamp(item_type) :: Timex.DateTime.t
end
