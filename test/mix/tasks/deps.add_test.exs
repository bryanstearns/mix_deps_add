defmodule Mix.Tasks.DepsAddTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Mix.Tasks.Deps.Add

  test "has documentation" do
    assert String.length(hd Add.__info__(:attributes)[:shortdoc]) > 0
  end

  defmodule FakeVersioner do
    def current(package_with_version) do
      case String.split(package_with_version, "_", parts: 2) do
        [_name, version] -> {:ok, version}
        _ -> {:ok, "0.0.0"}
      end
    end
  end

  defmodule FakeEditor do
    def read() do
      MixExsEditor.read("test/fixtures/end-to-end.exs")
    end
    def add(state, package_name, version) do
      MixExsEditor.add(state, package_name, version)
    end
    def write(state) do
      send(self(), {:write, state})
      :ok
    end
  end

  test "succeeds end-to-end" do
    assert capture_io(fn ->
      :ok = Add.run(["pkg_1.0.0", "pkg_2.0.0"],
                    versioner: FakeVersioner,
                    editor: FakeEditor)
    end) == ":pkg_1.0.0, \"~> 1.0.0\"\n:pkg_2.0.0, \"~> 2.0.0\"\n"

    assert_receive {:write, %MixExsEditor{}}
  end

  test "fails end-to-end" do
    output = capture_io(fn ->
      assert_raise Mix.Error, fn ->
        Add.run(["pkg_1.0.0", "poison", "pkg_2.0.0"],
                versioner: FakeVersioner,
                editor: FakeEditor)
      end
    end)
    assert output == ":pkg_1.0.0, \"~> 1.0.0\"\nOops: \"poison\" is already a dependency!\n:pkg_2.0.0, \"~> 2.0.0\"\n"

    refute_received {:write, %MixExsEditor{}}
  end
end
