defmodule Theriac do

  @moduledoc """
  Theriac is a implementation of clojure style transducers in elixir
  """

  def transduce enum, transducer do
    reducer = transducer.(fn {result, input} -> result ++ [input] end)
    Enum.reduce(enum,[], fn(input,result) -> reducer.({result,input}) end)
  end

  def map f do
    stateless_transducer fn 
      rf, result, input -> rf.({result, f.(input)}) 
    end
  end

  def remove f do
    stateless_transducer fn 
      rf, result, input -> unless f.(input), do: rf.({result,input}), else: result 
    end
  end

  def filter f do
    stateless_transducer fn 
      rf, result, input -> if f.(input), do: rf.({result,input}), else: result
    end
  end

  defp stateless_transducer reduction do
    fn rf ->
      fn
        {} -> rf.()
        {result} -> rf.({result})
        {result, input} -> reduction.(rf, result, input)
      end
    end
  end

end
