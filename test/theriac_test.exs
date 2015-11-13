defmodule TheriacTest do
  use ExUnit.Case
  import Theriac

  test "mapping transducer" do
    incrementing = map(fn inp -> inp + 1 end)
    reducer = fn {result, input} -> result + input end
    assert incrementing.(reducer).({0,1}) == 2
  end


end
