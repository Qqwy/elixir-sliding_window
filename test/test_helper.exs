ExUnit.start()

defmodule TestSW do
  @behaviour SlidingWindow.Behaviour

  @doc """
  Uses a single integer as aggregate type,

  and an {integer, timestamp} as item type.
  """

  defstruct count: 0, sum: 0, product: 1

  def empty_aggregate() do
    %__MODULE__{}
  end

  def add_item(agg, {int, timestamp}) do
    %__MODULE__{
      count: agg.count + 1,
      sum: agg.sum + int,
      product: agg.product * int
    }
  end

  def remove_item(agg, {int, timestamp}) do
    %__MODULE__{
      count: agg.count - 1,
      sum: agg.sum - int,
      product: div(agg.product, int)
    }
    |> IO.inspect
  end

  def extract_timestamp({int, timestamp}) do
    timestamp
  end

end
