defmodule SlidingWindowTest do
  use ExUnit.Case
  doctest SlidingWindow

  test "creation" do
    result =
      SlidingWindow.init(TestSW, 10, Timex.Duration.from_seconds(2), initial_data())
      # |> SlidingWindow.shift_stale_items()
      |> SlidingWindow.get_aggregates()
      |> IO.inspect

    assert result == %{0 => %TestSW{count: 1, product: 1, sum: 1},
                       1 => %TestSW{count: 2, product: 6, sum: 5},
                       2 => %TestSW{count: 2, product: 20, sum: 9},
                       3 => %TestSW{count: 2, product: 42, sum: 13},
                       4 => %TestSW{count: 2, product: 72, sum: 17},
                       5 => %TestSW{count: 2, product: 110, sum: 21},
                       6 => %TestSW{count: 2, product: 156, sum: 25},
                       7 => %TestSW{count: 2, product: 210, sum: 29},
                       8 => %TestSW{count: 2, product: 272, sum: 33},
                       9 => %TestSW{count: 2, product: 342, sum: 37}}
  end

  test "removal of stale items" do
    ten_sec_future = Timex.now() |> Timex.shift(seconds: 5)

    result =
      SlidingWindow.init(TestSW, 10, Timex.Duration.from_seconds(2), initial_data())
      |> SlidingWindow.shift_stale_items(ten_sec_future)
      |> SlidingWindow.get_aggregates()

    IO.inspect(result)

    assert result == %{0 => %TestSW{count: 0, product: 1, sum: 0},
                       1 => %TestSW{count: 0, product: 1, sum: 0},
                       2 => %TestSW{count: 0, product: 1, sum: 0},
                       3 => %TestSW{count: 1, product: 1, sum: 1},
                       4 => %TestSW{count: 2, product: 6, sum: 5},
                       5 => %TestSW{count: 2, product: 20, sum: 9},
                       6 => %TestSW{count: 2, product: 42, sum: 13},
                       7 => %TestSW{count: 2, product: 72, sum: 17},
                       8 => %TestSW{count: 2, product: 110, sum: 21},
                       9 => %TestSW{count: 2, product: 156, sum: 25}}
  end

  def initial_data() do
    initial_data = for int <- (100..1) do
      time = Timex.now |> Timex.shift(seconds: -int)
      {int, time}
    end
  end
end
