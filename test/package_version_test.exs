defmodule PackageVersionTest do
  use ExUnit.Case

  test "Finds the current version of a package" do
    assert PackageVersion.current("my_package") == "0.0.3"
  end
end
