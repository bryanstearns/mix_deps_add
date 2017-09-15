defmodule PackageVersionTest do
  use ExUnit.Case
  alias MixDepsAdd.PackageVersion

  defmodule FakeHexClient do
    def package_info("phoenix") do
      raw = File.read!("test/fixtures/raw_package_info")
      {info, []} = Code.eval_string(raw)
      {:ok, info}
    end
    def package_info(_) do
      {:error, :notfound}
    end
  end

  test "Finds the current version of a remote package" do
    assert {:versioned, "1.3.0-rc.0"} =
      PackageVersion.current("phoenix", FakeHexClient)
  end

  test "Returns the path to a local package" do
    assert {:relative, "end_to_end", "test/fixtures"} =
      PackageVersion.current("test/fixtures", :unused)
  end

  test "Returns an error if a remote package isn't found in Hex" do
    assert {:error, :notfound} =
      PackageVersion.current("sdlfkjsdfiuoiusdflks", FakeHexClient)
  end

  test "Returns an error if a local package path doesn't exist" do
    assert {:error, :nonexistant} =
      PackageVersion.current("../does_not_exist", :unused)
  end
end
