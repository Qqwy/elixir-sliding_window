defmodule SlidingWindow do
  defstruct [
    :window_size,
    :implementation,
    windows: %{},
    n_windows: 0
  ]

  @moduledoc """
  Documentation for SlidingWindow.
  """

  def init(behaviour_implementation_module, n_windows, window_size, initial_contents) do
    empty_aggregate = behaviour_implementation_module.empty_aggregate
    windows =
      (n_windows..1)
      |> Enum.map(&({&1, Window.init_window(empty_aggregate)}))
  end

  def add_item(sliding_window_struct, item) do
  end

  def update do
  end
end
