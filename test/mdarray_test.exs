defmodule MDArrayTest do
  use ExUnit.Case
  doctest MDArray

  setup do
    %{ array1: MDArray.new([10]),
       array3: MDArray.new([3,3,3]),
       array5: MDArray.new([5, 5, 5, 5, 5]) }
  end

  test "get undefined element returns :undefined", context do
    assert MDArray.get(context.array1, [0]) == :undefined
    assert MDArray.get(context.array5, [0, 1, 2, 3, 4]) == :undefined
  end

  test "get out of bounds element raises an error", context do
    assert_raise ArgumentError, "index out of bounds", fn ->
      MDArray.get(context.array1, [10])
    end

    assert_raise ArgumentError, "index out of bounds", fn ->
      MDArray.get(context.array1, [-1])
    end

    assert_raise ArgumentError, "index out of bounds", fn ->
      MDArray.get(context.array5, [0, 0, 0, 0, 5])
    end
  end

  test "get dimension mismatch raises an error", context do
    assert_raise ArgumentError, "dimension mismatch", fn ->
      MDArray.get(context.array1, [1, 2])
    end

    assert_raise ArgumentError, "dimension mismatch", fn ->
      MDArray.get(context.array5, [0, 1, 2, 3])
    end

    assert_raise ArgumentError, "dimension mismatch", fn ->
      MDArray.get(context.array5, [1, 2, 3, 4, 0, 1])
    end
  end

  test "put dimension mismatch raises an error", context do
    assert_raise ArgumentError, "dimension mismatch", fn ->
      MDArray.put(context.array5, [0, 1, 0, 1], :test)
    end

    assert_raise ArgumentError, "dimension mismatch", fn ->
      MDArray.put(context.array5, [1, 1, 1, 1, 0, 0], :test)
    end
  end

  test "put index out of range raises an error", context do
    assert_raise ArgumentError, "index out of bounds", fn ->
      MDArray.put(context.array5, [1, 2, 3, 4, 5], :test)
    end

    assert_raise ArgumentError, "index out of bounds", fn ->
      MDArray.put(context.array1, [-1], :test)
    end
  end

  test "can add entries to the array", context do
    arr = context.array1
    |> MDArray.put([0], 0)
    |> MDArray.put([1], 1)
    |> MDArray.put([2], 2)

    assert arr != context.array1
  end

  test "can retrieve value after put", context do
    a = MDArray.put(context.array5, [0, 1, 2, 3, 4], :test)
    assert MDArray.get(a, [0, 1, 2, 3, 4]) == :test
  end

  test "only the correct value is set by put", context do
    a = MDArray.put(context.array3, [1, 1, 1], :test)

    for i <- 0..2, j <- 0..2, k <- 0..2, i != 1 or j != 1 or k != 1 do
      assert MDArray.get(a, [i,j,k]) == :undefined
    end
  end

  test "set a value twice results in second value", context do
    a = MDArray.put(MDArray.put(context.array1, [0], :test1), [0], :test2)
    assert MDArray.get(a, [0]) == :test2
  end

  test "update on undefined value set default", context do
    a = MDArray.update(context.array1, [0], :default, fn _, _ -> :nondefault end)

    assert MDArray.get(a, [0]) == :default
  end

  test "update on defined value applies the update function", context do
    a = context.array1 |> MDArray.put([1], 1) |> MDArray.update([1], :default, fn x, _ -> x*2 end)

    assert MDArray.get(a, [1]) == 2
  end

  test "defined returns only those indices that have been set", context do
    a = context.array3
    |> MDArray.put([0, 0, 0], 0)
    |> MDArray.put([1, 1, 1], 1)
    |> MDArray.put([2, 2, 2], 2)

    defined = MDArray.defined(a)

    assert defined == MapSet.new([[0, 0, 0], [1, 1, 1], [2, 2, 2]])
  end

  test "empty array has size 0", context do
    assert MDArray.size(context.array1) == 0
    assert MDArray.size(context.array3) == 0
    assert MDArray.size(context.array5) == 0
  end

  test "size of the array reflects the number of unique insertions", %{array1: array} do
    a = MDArray.put(array, [0], :zero) |> MDArray.put([1], :one) |> MDArray.put([0], :three)
    assert MDArray.size(a) == 2
  end

  test "put_if stores the new value for undefined entries, regardless of the predicate", %{array1: array} do
    a = MDArray.put_if(array, [2], :new, fn _, _ -> false end)
    assert MDArray.size(a) == 1
    assert MDArray.get(a, [2]) == :new
  end

  test "put_if does not store the new value if the predicate fails", %{array1: array} do
    a = MDArray.put(array, [4], :old)
    |> MDArray.put_if([4], :new, fn _, _ -> :false end)

    assert MDArray.get(a, [4]) == :old
  end

  test "put_if stores the new value if the predicate succeeds", %{array1: array} do
    a = MDArray.put(array, [2], 0)
    |> MDArray.put_if([2], 1, fn current, new -> current < new end)

    assert MDArray.get(a, [2]) == 1
  end

end
