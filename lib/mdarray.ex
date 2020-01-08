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

  @doc """
  Gets an element from the array.
  """
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

  @doc """
  Insert and element into the array.
  """
  def put(array, index, value) do
    check_index(array.dimensions, index)
    %{ array | data: put_internal(array.data, index, value) }
  end

  defp put_internal(:undefined, index, value) do
    put_internal(:array.new(), index, value)
  end

  defp put_internal(array, [ix], value) do
    :array.set(ix, value, array)
  end

  defp put_internal(array, [ix|index], value) do
    :array.set(
      ix,
      put_internal(:array.get(ix, array), index, value),
      array
    )
  end

  @doc """
  Update the value stored at `index` by applying `update_fun` if it is
  defined, otherwise store the default.

  `update_fun` takes two parameters, the current stored value and `default`.
  """
  def update(array, index, default, update_fun) do
    case get(array, index) do
      :undefined ->
        put(array, index, default)
      current ->
        put(array, index, update_fun.(current, default))
    end
  end
end
