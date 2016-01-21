defmodule Theriac do

  @moduledoc """
  Theriac is a implementation of clojure style transducers in elixir
  """

  def transduce enum, {initialState, transducer} do
    reducer = transducer.(fn 
      {{result, state}, input} -> {result ++ [input], state}
    end)
    case Enum.reduce(enum,{[],initialState}, fn(input,rs) -> reducer.({rs,input}) end) do
      {:reduced, {result,_state}} -> result
      {r,_s} -> r
    end
  end

  def comb list do
    {:stateless, Enum.reduce(list, fn i -> i end,fn({:stateless, f},c) -> fn i -> c.(f.(i)) end end)}
  end

  defp  stateless_transducer reduction do
    stateful_transducer :stateless, reduction
  end

  defp stateful_transducer initialState, reduction do
    {initialState, fn rf ->
      fn
        {{:reduced, rs}, _input} -> {:reduced, rs}
        {rs, input} -> reduction.(rf, rs, input)
      end
    end}
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

  def take count do
    stateful_transducer 0, fn
      rf, {result,state}, input -> 
        if state < count do
          rf.({{result,state+1},input})
        else
          {:reduced,{result,state}}
        end
    end
  end

  def scan initialVal, f do
    stateful_transducer initialVal, 
    fn rf, {result,state}, input -> 
      current = f.(input, state)
      rf.({{result,current},current})
    end
  end

end
