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

  def init(behaviour_implementation, n_windows, window_size = %Timex.Duration{}, initial_contents \\ [], now \\ Timex.now()) do
    empty_aggregate = behaviour_implementation.empty_aggregate
    empty_windows =
      ((n_windows-1)..0)
      |> Enum.map(&({&1, Window.init_window(empty_aggregate)}))

    lower_bound = time_threshold(now, window_size, n_windows)
    content_pairs =
      initial_contents
      |> Enum.map(fn item -> {behaviour_implementation.extract_timestamp(item), item} end)
      |> drop_while_stale(lower_bound)

    windows =
      fill_windows(behaviour_implementation, now, window_size, empty_windows, content_pairs)
      |> Enum.into(%{})

    %__MODULE__{window_size: window_size, implementation: behaviour_implementation, windows: windows, n_windows: n_windows}
  end

  defp fill_windows(_, _, _, [], _), do: []
  defp fill_windows(impl, now, window_size, [{window_index, window} | windows], contents) do
    threshold = time_threshold(now, window_size, window_index)
    {old, rest} = split_while_stale(contents, threshold)
    [{window_index, fill_window(impl, window, old)} | fill_windows(impl, now, window_size, windows, rest)]
  end

  defp fill_window(impl, window, item_pairs) do
    Enum.reduce(item_pairs, window, &Window.add_item(&2, &1, impl))
  end

  defp time_threshold(now, window_size, window_index) do
    Timex.subtract(now, Timex.Duration.scale(window_size, window_index))
  end

  defp split_while_stale(content_pairs, threshold) do
    Enum.split_while(content_pairs, fn {timestamp, item} -> Timex.compare(timestamp, threshold) == -1 end)
  end

  defp drop_while_stale(content_pairs, threshold) do
    {_, rest} = split_while_stale(content_pairs, threshold)
    rest
  end

  def add_item(sliding_window, item) do
    # windows = Map.put(sliding_window.windows, 1, fn window -> Window.add_item(sliding_window.implementation, window, item) end)
    # Map.put(sliding_window, :windows, windows)
    timestamp = sliding_window.implementation.extract_timestamp(item)
    put_in(sliding_window.windows[1], Window.add_item(sliding_window.implementation, sliding_window.windows[1], {timestamp, item}))
  end

  def shift_stale_items(sliding_window, now \\ Timex.now()) do
    put_in(sliding_window.windows, shift_stale_items(sliding_window.implementation, now, sliding_window.window_size, [], [], sliding_window.windows |> Enum.sort))
  end

  defp shift_stale_items(_impl, _now, _window_size, _stale_items, accum, []), do: accum |> Enum.into(%{})
  defp shift_stale_items(impl, now, window_size, stale_items, accum, [{window_index, window} | windows]) do
    threshold = time_threshold(now, window_size, window_index)
    updated_window = fill_window(impl, window, stale_items)
    {new_stale_items, updated_window} = Window.remove_stale_items(updated_window, impl, threshold)
    updated_accum = [{window_index, updated_window} | accum]
    shift_stale_items(impl, now, window_size, new_stale_items, updated_accum, windows)
  end

  def get_aggregates(sliding_window) do
    Enum.into(sliding_window.windows, %{}, fn {key, window} -> {key, Window.get_aggregate(window)} end)
  end
end
