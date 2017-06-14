defmodule SlidingWindowTest do
  use ExUnit.Case
  doctest SlidingWindow

  test "creation" do
    SlidingWindow.init(TestSW, 10, Timex.Duration.from_seconds(1), initial_data())
  end

  test "removing stale" do
    SlidingWindow.init(TestSW, 10, Timex.Duration.from_seconds(1), initial_data())
    |> SlidingWindow.shift_stale_items()
  end

  def initial_data() do
    initial_data = for int <- (100..1) do
      time = Timex.now |> Timex.shift(seconds: int)
      {int, time}
    end
  end
end
