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

end
