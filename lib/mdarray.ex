defmodule MDArray do
  @moduledoc """
  Documentation for MDArray.
  """

  defstruct [:dimensions, :data]

  @doc """
  Create an empty array with the given dimensions.
  """
  def new(dimensions) do
    %__MODULE__{
      dimensions: dimensions,
      data: :array.new(hd(dimensions), [default: :undefined])
    }
  end

  @doc """
  Gets an element from the array.
  """
  def get(%{dimensions: dimensions}, index) when length(index) != length(dimensions) do
    raise ArgumentError, "dimension mismatch"
  end

  def get(array, index) do
    check_index(array.dimensions, index)
    List.foldl(
      index,
      array.data,
      fn
        _, :undefined ->
          :undefined
        i, acc ->
          :array.get(i, acc)
      end)
  end

  defp check_index([], []), do: :ok

  defp check_index(_, []), do: raise ArgumentError, "dimension mismatch"

  defp check_index([], _), do: raise ArgumentError, "dimension mismatch"

  defp check_index([d|dims], [i|index]) do
    if d > i and i >= 0 do
      check_index(dims, index)
    else
      raise ArgumentError, "index out of bounds"
    end
  end

end
