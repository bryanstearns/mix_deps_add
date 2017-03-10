defmodule PackageVersionTest do
  use ExUnit.Case

  defmodule FakeHTTPoison do
    def get("https://hex.pm/api/packages/phoenix") do
      {:ok, body} = File.read("test/fixtures/raw_package_info.json")
      {:ok, %{status_code: 200, body: body}}
    end
    def get(_) do
      {:error, :notfound}
    end
  end

  test "Finds the current version of a package" do
    assert {:ok, "1.3.0-rc.0"} = PackageVersion.current("phoenix", FakeHTTPoison)
  end

  test "Returns an error if the package isn't found" do
    assert {:error, :notfound} = PackageVersion.current("sdlfkjsdfiuoiusdflks")
  end
end
