defmodule MixExsEditorTest do
  use ExUnit.Case

  test "reads good dependencies" do
    {_before, deps, _after, _filename} = MixExsEditor.read("test/fixtures/good_mix.exs")
    assert [
      ":foobar, path: \"path/to/foobar\"",
      ":foobar, git: \"https://github.com/elixir-lang/foobar.git\", tag: \"0.1\"",
      ":plug, \">= 0.4.0\""
    ] == deps
  end

  test "handles interesting cases" do
    assert {:error, :no_deps} = MixExsEditor.read("test/fixtures/no_deps.exs")
    assert {:error, :ambiguous_deps} = MixExsEditor.read("test/fixtures/ambiguous_deps.exs")
    assert {:error, :unparsable_deps} = MixExsEditor.read("test/fixtures/unparsable_deps.exs")
    assert {_, [], _, _} = MixExsEditor.read("test/fixtures/empty.exs")
  end

  test "inserts a new dependency in sorted order" do
    expected = """
  defp deps do
    [
      {:bar, ...},
      {:baz, "~> 1.0.0"},
      {:foo, ...}
    ]
  end
""" |> String.trim_trailing
    assert {^expected, "name"} = MixExsEditor.insert({
      "  defp deps do",
      [":foo, ...", ":bar, ..."],
      "  end",
      "name",
    }, "baz", "1.0.0")
  end

  test "rejects duplicates" do
    assert {:error, :name_conflict} = MixExsEditor.ensure_unique_name({
      "  defp deps do",
      [":foo, ..."],
      "  end",
      "name",
    }, "foo")
  end

  describe "end-to-end" do
    setup do
      fixture = "test/fixtures/tmp_our_mix.exs"
      unversioned_content = File.read!("mix.exs")
      |> String.replace(~r/version: \"[^\"]+\",/, "version: \"HARDCODED\",")
      |> String.replace(~r/elixir: \"[^\"]+\",/, "elixir: \"HARDCODED\",")
      #on_exit(fn -> File.rm(fixture) end)
      File.write!(fixture, unversioned_content)

      {:ok, fixture: fixture}
    end

    test "works", context do
      assert :ok = MixExsEditor.add("idna", "4.0.0", context[:fixture])
      assert File.read!(context[:fixture]) ==
             File.read!("test/fixtures/good_our_mix.exs")
    end
  end
end
