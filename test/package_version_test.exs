defmodule PackageVersionTest do
  use ExUnit.Case

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

  test "Finds the current version of a package" do
    assert {:ok, "1.3.0-rc.0"} =
      PackageVersion.current("phoenix", FakeHexClient)
  end

  test "Returns an error if the package isn't found" do
    assert {:error, :notfound} =
      PackageVersion.current("sdlfkjsdfiuoiusdflks", FakeHexClient)
  end
end
