defmodule MixExsEditorTest do
  use ExUnit.Case
  alias MixDepsAdd.MixExsEditor

  test "reads a file" do
    %{before: stuff_before, deps: deps, after: stuff_after, filename: filename, results: []} =
      MixExsEditor.read("test/fixtures/good_mix.exs")

    assert "  # These are the example dependencies listed by `mix help deps`\n  defp deps do" = stuff_before
    assert [
      ":foobar, path: \"path/to/foobar\"",
      ":foobar, git: \"https://github.com/elixir-lang/foobar.git\", tag: \"0.1\"",
      ":plug, \">= 0.4.0\""] = deps
    assert "  end\n" = stuff_after
    assert "test/fixtures/good_mix.exs" = filename
  end

  test "handles interesting cases" do
    assert %{results: [:no_deps]} = MixExsEditor.read("test/fixtures/no_deps.exs")
    assert %{results: [:ambiguous_deps]} = MixExsEditor.read("test/fixtures/ambiguous_deps.exs")
    assert %{results: [:unparsable_deps]} = MixExsEditor.read("test/fixtures/unparsable_deps.exs")
    assert %{results: [], deps: []} = MixExsEditor.read("test/fixtures/empty.exs")
  end

  test "inserts new dependencies in sorted order" do
    before_state = %MixExsEditor{
      before: "  defp deps do",
      deps: [":foo, ...", ":bar, ..."],
      after: "  end"
    }

    with_baz = MixExsEditor.add(before_state, "baz", version: "1.0.0")
    assert %{results: [{:versioned, "baz", "1.0.0"}], deps: [":bar, ...", ":baz, \"~> 1.0.0\"", ":foo, ..."]} = with_baz

    with_baz_and_quux = MixExsEditor.add(with_baz, "quux", path: "../quux")
    assert %{results: [{:relative, "quux", "../quux"}, {:versioned, "baz", "1.0.0"}],
             deps: [":bar, ...", ":baz, \"~> 1.0.0\"", ":foo, ...", ":quux, path: \"../quux\""]} = with_baz_and_quux
  end

  test "rejects duplicates" do
    before_state = %MixExsEditor{
      before: "  defp deps do",
      deps: [":foo, ..."],
      after: "  end",
      filename: "filename"
    }

    assert %{results: [{:name_conflict, "foo"}]} =
      MixExsEditor.add(before_state, "foo", versioned: "0.0.0")
  end

  describe "end-to-end" do
    setup do
      original = "test/fixtures/mix.exs"
      copy = "test/fixtures/end-to-end-copy.exs"
      on_exit(fn -> File.rm(copy) end)
      File.cp(original, copy)

      {:ok, fixture_path: copy}
    end

    test "succeeds correctly", context do
      :ok = MixExsEditor.read(context[:fixture_path])
      |> MixExsEditor.add("idna", version: "4.0.0")
      |> MixExsEditor.write()

      assert File.read!(context[:fixture_path]) ==
             File.read!("test/fixtures/end-to-end-result.exs")
    end

    test "fails correctly", context do
      assert {:error, [{:name_conflict, "poison"},
                       {:versioned, "foo", "1.0.0"}]} = MixExsEditor.read(context[:fixture_path])
        |> MixExsEditor.add("foo", version: "1.0.0")
        |> MixExsEditor.add("poison", version: "6.6.6")
        |> MixExsEditor.write()
    end
  end
end
