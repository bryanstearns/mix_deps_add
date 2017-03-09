defmodule Mix.Tasks.DepsAddTest do
  use ExUnit.Case
  alias Mix.Tasks.Deps.Add

  test "has documentation" do
    assert String.length(hd Add.__info__(:attributes)[:shortdoc]) > 0
  end
end
