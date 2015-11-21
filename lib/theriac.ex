defmodule Theriac do

  @moduledoc """
  Theriac is a implementation of clojure style transducers in elixir
  """

  def transduce enum, transducer do
    reducer = transducer.(fn 
      {{:reduced, result}, input} -> {:reduced, result}
      {result, input} -> result ++ [input] 
    end)
    case  Enum.reduce(enum,[], fn(input,result) -> reducer.({result,input}) end) do
      {:reduced, r} -> r
      r -> r
    end
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

  def take_while f do
    stateless_transducer fn 
      rf, result, input -> if f.(input), do: rf.({result,input}), else: {:reduced, result}
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
