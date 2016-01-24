defmodule TheriacTest do
  use ExUnit.Case
  doctest Theriac
  import Theriac

  test "combining multiple stateless transducers" do
    transducer = comb [filter(fn i -> i < 10 end), map(fn i -> i * 2 end)]
    result = transduce([1,2,7,9,11,22,3,10], transducer)
    assert result == [2,4,14,18,6]
  end

  test "combining stateful and stateless transducers" do
    transducer = comb [filter(fn i -> i < 10 end), take(3), map(fn i -> i * 2 end)]
    result = transduce([1,2,7,9,11,22,3,10], transducer)
    assert result == [2,4,14]
  end

end
