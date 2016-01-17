defmodule TheriacTest do
  use ExUnit.Case
  import Theriac

  test "map" do
    result = transduce([1,2,3],map(fn inp -> inp + 1 end))
    assert result == [2,3,4]
  end

  test "filter" do
    result = transduce([1,2,3],filter(fn inp -> inp > 2 end))
    assert result == [3]
  end

  test "remove" do
    result = transduce([1,2,3],remove(fn inp -> inp > 2 end))
    assert result == [1,2]
  end

  test "take while" do
    result = transduce([1,3,5,2,4],take_while(fn inp -> inp < 5 end))
    assert result == [1,3]
  end

  test "take" do
    result = transduce([1,2,3,4,5,6,7,8,9], take(2))
    assert result == [1,2]
  end

  test "scan" do
    result = transduce([1,2,3,4,5], scan(0, fn inp, acc -> inp + acc end))
    assert result == [1,3,6,10,15]
  end

  test "combining multiple stateless transducers" do
    transducer = comb [filter(fn i -> i < 10 end), map(fn i -> i * 2 end)]
    result = transduce([1,2,7,9,11,22,3,10], transducer)
    assert result == [2,4,14,18,6]
  end

end
