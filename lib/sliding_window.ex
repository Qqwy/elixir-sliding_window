defmodule SlidingWindow do
  defstruct [
    :window_size,
    :implementation,
    windows: %{},
    n_windows: 0
  ]

  alias SlidingWindow.Window

  @moduledoc """
  Documentation for SlidingWindow.
  """

  def init(behaviour_implementation, n_windows, window_size = %Timex.Duration{}, initial_contents \\ []) do
    empty_aggregate = behaviour_implementation.empty_aggregate
    now = Timex.now()
    empty_windows =
      (n_windows..1)
      |> Enum.map(&({&1, Window.init_window(empty_aggregate)}))

    content_pairs = Enum.map(initial_contents, fn item -> {behaviour_implementation.extract_timestamp(item), item} end)
    IO.inspect(content_pairs)


    windows =
      fill_windows(behaviour_implementation, now, window_size, empty_windows, content_pairs)
      |> Enum.into(%{})


    %__MODULE__{window_size: window_size, implementation: behaviour_implementation, windows: windows, n_windows: n_windows}
    |> IO.inspect
  end

  defp fill_windows(_, _, _, [], _), do: []
  defp fill_windows(impl, now, window_size, [{window_index, window} | windows], contents) do
    threshold = Timex.subtract(now, Timex.Duration.scale(window_size, window_index - 1))
    IO.inspect({threshold, contents})
    [old, rest] = Enum.split_while(contents, fn {timestamp, item} -> Timex.compare(timestamp, threshold) == -1 end)
    IO.inspect([old, rest])
    [{window_index, fill_window(impl, window, old)} | fill_windows(impl, now, window_size, windows, rest)]
  end

  defp fill_window(impl, window, items) do
    Enum.reduce(items, window, &Window.add_item(&1, &2, impl))
  end

  def add_item(sliding_window, item) do
    # windows = Map.put(sliding_window.windows, 1, fn window -> Window.add_item(sliding_window.implementation, window, item) end)
    # Map.put(sliding_window, :windows, windows)
    put_in(sliding_window.windows[1], Window.add_item(sliding_window.implementation, sliding_window.windows[1], item))
  end

  def shift_stale_items(sliding_window) do
    now = Timex.now()
    shift_stale_items(sliding_window.implementation, now, [], [], sliding_window.windows |> Enum.into([]))
  end

  defp shift_stale_items(impl, now, stale_items, accum, []), do: accum |> Enum.into(%{})
  defp shift_stale_items(impl, now, stale_items, accum, [{window_index, window} | windows]) do
    updated_window = fill_window(impl, window, stale_items)
    {new_stale_items, window} = Window.remove_stale_items(updated_window, impl, now)
    updated_accum = [{window_index, updated_window} | accum]
    shift_stale_items(impl, now, new_stale_items, updated_accum, windows)
  end
end
