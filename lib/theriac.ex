defmodule Theriac do
  @moduledoc """
  Theriac is a implementation of clojure style transducers in elixir
  """

  def map f do
    fn rf ->
      fn
        {} -> rf.()
        {result} -> rf.({result})
        {result, input} -> rf.({result, f.(input)})
      end
    end
  end

end
