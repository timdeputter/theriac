defmodule Theriac do
  @moduledoc """
  Theriac is a implementation of clojure style transducers in elixir
  """

  def transduce enum, transducer do
    reducer = transducer.(fn {r, input} -> r ++ [input] end)
    Enum.reduce(enum,[], fn(x,acc) -> reducer.({acc,x}) end)
  end

  def map f do
    fn rf ->
      fn
        {} -> rf.()
        {result} -> rf.({result})
        {result, input} -> rf.({result, f.(input)})
      end
    end
  end

  def filter f do
    fn rf ->
      fn
        {} -> rf.()
        {result} -> rf.({result})
        {result, input} -> 
          if f.(input) do
            result = rf.({result,input})
          end
          result
      end
    end
  end

end
