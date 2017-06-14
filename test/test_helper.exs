ExUnit.start()

defmodule TestSW do
  @behaviour SlidingWindow.Behaviour

  defmodule Transaction do
    defstruct [:value, :created_at]
    def new(value, created_at) do
      %__MODULE__{value: value, created_at: created_at}
    end
  end

  defstruct count: 0, sum: 0, product: 1

  def empty_aggregate() do
    %__MODULE__{}
  end

  def add_item(agg, %Transaction{value: int}) do
    %__MODULE__{agg |
      count: agg.count + 1,
      sum: agg.sum + int,
      product: agg.product * int
    }
  end

  def remove_item(agg, %Transaction{value: int}) do
    %__MODULE__{agg |
      count: agg.count - 1,
      sum: agg.sum - int,
      product: div(agg.product, int)
    }
  end

  def extract_timestamp(%Transaction{created_at: timestamp}) do
    timestamp
  end

end
