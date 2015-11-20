defmodule TheriacTest do
  use ExUnit.Case
  import Theriac

  test "mapping transducer" do
    result = transduce([1,2,3],map(fn inp -> inp + 1 end))
    assert result == [2,3,4]
  end

  test "filtering transducer" do
    result = transduce([1,2,3],filter(fn inp -> inp > 2 end))
    assert result == [3]
  end

end
