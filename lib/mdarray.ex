defmodule MDArray do
  @moduledoc """
  Documentation for MDArray.
  """

  defstruct [:dimensions, :data, :indices]

  @doc """
  Create an empty array with the given dimensions.
  """
  def new(dimensions) do
    %__MODULE__{
      dimensions: dimensions,
      data: :array.new(hd(dimensions), [default: :undefined]),
      indices: MapSet.new()
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
    %{ array |
       data: put_internal(array.data, index, value),
       indices: MapSet.put(array.indices, index) }
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

  @doc """
  Add `new` to the array at `index` if `index` is undefined or
  `predicate.(MDArray.get(array, index), new)` is `true`.
  """
  def put_if(array, index, new, predicate) do
    update(array, index, new,
      fn current, new ->
        if predicate.(current, new) do
          new
        else
          current
        end
      end)
  end

  @doc """
  Returns a set containing the indices that have defined entries.

  ## Examples

    iex> MDArray.defined(MDArray.new([2,2,2,2]))
    #MapSet<[]>

  """
  def defined(array) do
    array.indices
  end

  @doc """
  Get the number of elements in the array that are not undefined.
  """
  def size(array) do
    MapSet.size(array.indices)
  end

  @doc """
  Get the capacity of the array.

  ## Examples

    iex> MDArray.capacity(MDArray.new([10]))
    10

    iex> MDArray.capacity(MDArray.new([10, 10, 100]))
    10000

  """
  def capacity(%{dimensions: dimensions}) do
    Enum.reduce(dimensions, fn x, acc -> x * acc end)
  end

  @doc """
  Get the dimensions of the array.

  ## Examples

    iex> MDArray.dimensions(MDArray.new([10]))
    [10]

    iex> MDArray.dimensions(MDArray.new([5, 4, 3, 2, 1]))
    [5, 4, 3, 2, 1]
  """
  def dimensions(array) do
    array.dimensions
  end
end
