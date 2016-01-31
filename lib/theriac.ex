defmodule Theriac do

  @moduledoc """
  Theriac is an implementation of clojure style transducers in elixir.
  """

  @doc ~S"""
  Transduces a given enumerable into a list.

  ## Examples

      iex> Theriac.transduce([1,2,7,9], Theriac.take(1))
      [1]
  """
  def transduce enum, {id, initial_state, transducer} do
    transduce enum, {[{id, initial_state}], transducer}
  end

  def transduce enum, {initial_state, transducer} do
    reducer = transducer.(fn 
      {:reduced, rs}, _input -> {:reduced, rs}
      {result, state}, input -> {result ++ [input], state}
    end)
    case Enum.reduce(enum,{[],initial_state}, fn(input,rs) -> reducer.(rs,input) end) do
      {:reduced, {result, _state}} -> result
      {r, _s} -> r
    end
  end

  @doc ~S"""
  Combines multiple transducers into one combined transducers.
  The functions are applied in the order they appear in the given list.

  ## Examples

      iex> Theriac.transduce([1,2,7,9,11,22,3,10], Theriac.comb [Theriac.take(3), Theriac.map(fn i -> i * 2 end)])
      [2,4,14]
  """
  def comb list do
    Enum.reduce(list, {[], fn i -> i end},
      fn({id, initial_state, f},{cummulated_initial_state, c}) ->
        {cummulated_initial_state ++ [{id, initial_state}], fn i -> c.(f.(i)) end} end)
  end

  @doc ~S"""
  Maps the given values over the given function and passes the result to the step function.

  ## Examples

      iex> Theriac.transduce([1,2,3],Theriac.map(fn inp -> inp + 1 end))
      [2,3,4]
  """
  def map f do
    transducer new_id, :stateless, fn 
      rf, result, input -> rf.(result, f.(input)) 
    end
  end

  @doc ~S"""
  Doesn't call the step function for every element for which the given function does return true.

  ## Examples

      iex>Theriac.transduce([1,2,3],Theriac.remove(fn inp -> inp > 2 end))
      [1,2]
  """
  def remove f do
    transducer new_id, :stateless, fn 
      rf, result, input -> unless f.(input), do: rf.(result, input), else: result 
    end
  end

  @doc ~S"""
  Calls the step function for every element for which the given function does return true.

  ## Examples

      iex>Theriac.transduce([1,2,3],Theriac.remove(fn inp -> inp > 2 end))
      [1,2]
  """
  def filter f do
    transducer new_id, :stateless, fn 
      rf, result, input -> if f.(input), do: rf.(result, input), else: result
    end
  end

  @doc ~S"""
  Calls the given function for every element. 
  Calls the step function until the given function returns false for the first time.

  ## Examples

      iex>Theriac.transduce([1,3,5,2,4],Theriac.take_while(fn inp -> inp < 5 end))
      [1,3]
  """
  def take_while f do
    transducer new_id, :stateless, fn 
      rf, result, input -> if f.(input), do: rf.(result, input), else: {:reduced, result}
    end
  end

  @doc ~S"""
  Calls the step function for the first n elements.
  ## Examples

      iex>Theriac.transduce([1,11,3,4,5,6,7,8,9], Theriac.take(2))
      [1,11]
  """
  def take count do
    stateful_transduce 0, fn step, _skip, state, input ->
      if state < count do
        step.(state+1, input)
      else
        step.({:reduced, state+1}, input)
      end
    end
  end

  @doc ~S"""
  Skips the first n elements and calls the step function for the n+1th element.

  ## Examples

      iex>Theriac.transduce([1,11,3,4,5,6,7,8,9], Theriac.skip(5))
      [6,7,8,9]
  """
  def skip count do
    stateful_transduce 0, fn step, skip, state, input ->
      if state >= count do
        step.(state+1, input)
      else
        skip.(state+1) 
      end
    end
  end

  @doc ~S"""
  Calls the given function with every element and the result of calling 
  the function with the previous element or the given initial value if it's the first element.
  Calls the step function with every result.
  ## Examples

      iex>Theriac.transduce([1,2,3,4,5], Theriac.scan(0, fn inp, acc -> inp + acc end))
      [1,3,6,10,15]
  """
  def scan initialVal, f do
    stateful_transduce initialVal, fn step, _skip, state, input ->
      current = f.(input, state)
      step.(current,current)
    end
  end

  @doc ~S"""
  Calls the step function for every element, if no previous element was equal to the current element.
  ## Examples

      iex>Theriac.transduce([1,3,2,3,2,4,5], Theriac.distinct)
      [1,3,2,4,5]
  """
  def distinct do
    stateful_transduce [], fn step, skip, state, input ->
      if(Enum.all?(state, fn e -> e != input end)) do
        new_state = state ++ [input]
        step.(new_state, input)
      else
        skip.(state)
      end
    end
  end

  defp stateful_transduce initialVal, func do
    id = new_id
    transducer id, initialVal, 
    fn rf, {result, states}, input -> 
      state = get_state states, id
      continuation = fn 
        {:reduced, new_state}, input ->
          rf.({:reduced, {result, update_state(states, id, new_state)}}, input)
        new_state, input ->
          rf.({result, update_state(states, id, new_state)}, input)
        end
      ret = fn new_state ->
        {result, update_state(states, id, new_state)}
      end
      func.(continuation, ret, state, input)
    end
  end

  defp transducer id, initialState, reduction do
    {id, initialState, fn rf ->
      fn
        {:reduced, rs}, _input -> {:reduced, rs}
        rs, input -> reduction.(rf, rs, input)
      end
    end}
  end

  defp get_state states, given_id do
    {_id, s} = List.keyfind(states, given_id, 0)
    s
  end

  defp update_state states, given_id, new_state do
    List.keyreplace(states, given_id, 0, {given_id, new_state})
  end

  defp new_id do
    UUID.uuid1()
  end

end
