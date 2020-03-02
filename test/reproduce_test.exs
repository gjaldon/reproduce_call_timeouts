defmodule ReproduceTest do
  use ExUnit.Case
  doctest Reproduce

  test "greets the world" do
    assert Reproduce.hello() == :world
  end
end
