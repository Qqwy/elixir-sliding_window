ExUnit.start()

defmodule TestSW do
  @behaviour SlidingWindow.Behaviour

  @doc """
  Uses a single integer as aggregate type,

  and an {integer, timestamp} as item type.
  """

  def empty_aggregate() do
    0
  end

  def add_item(agg, {int, timestamp}) do
    agg + int
  end

  def remove_item(agg, {int, timestamp}) do
    agg - int
  end

  def extract_timestamp({int, timestamp}) do
    timestamp
  end

end
