defmodule MDArrayTest do
  use ExUnit.Case
  doctest MDArray

  setup do
    %{ array1: MDArray.new([10]),
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
end
