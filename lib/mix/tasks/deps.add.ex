defmodule Mix.Tasks.Deps.Add do
  use Mix.Task
  alias MixDepsAdd.MixExsEditor
  alias MixDepsAdd.PackageVersion

  @shortdoc "Adds new dependencies to mix.exs"

  @mix_exs_parsing_errors %{
    no_deps: "deps/0 function not found.",
    ambiguous_deps: "looks like there's more than one deps/0 function?",
    no_deps_end: "end of deps/0 function not found.",
    unparsable_deps: "found the deps/0 function, but couldn't figure out its content."
  }

  def run(package_names, opts \\ [])
  def run([], _opts) do
    IO.puts("Usage: mix deps.add PACKAGE_NAME…")
    System.halt(2)
  end
  def run(package_names, opts) do
    editor = Keyword.get(opts, :editor, MixExsEditor)
    versioner = Keyword.get(opts, :versioner, PackageVersion)

    package_names
    |> Enum.reduce(editor.read(), fn name, state ->
      add_package(state, name, editor, versioner)
    end)
    |> announce_results()
    |> editor.write()
  end

  def add_package(state, package_name, editor, versioner) do
    case versioner.current(package_name) do
      {:versioned, version} -> editor.add(state, package_name, version: version)
      {:relative, name, path} -> editor.add(state, name, path: path)
      error -> error
    end
  end

  defp announce_results(%{results: []}) do
    Mix.raise "Oops: Nothing done?!"
  end
  defp announce_results(%{results: results} = state) do
    results
    |> Enum.reverse
    |> Enum.each(&announce_result/1)

    if !MixExsEditor.success?(results) do
      Mix.raise("mix.exs unchanged.")
    end
    state
  end

  defp announce_result({:versioned, name, version}) do
    IO.puts(":#{name}, \"~> #{version}\"")
  end
  defp announce_result({:relative, name, path}) do
    IO.puts(":#{name}, path: \"#{path}\"")
  end
  defp announce_result({:name_conflict, name}) do
    IO.puts("Oops: \"#{name}\" is already a dependency!")
  end
  defp announce_result({:notfound, name}) do
    IO.puts("Oops: https://hex.pm/ doesn't seem to have a package named \"#{name}\".")
  end
  defp announce_result(parsing_error) do
    text = Map.get(@mix_exs_parsing_errors, parsing_error, nil)
    if text do
      Mix.raise "Oops: mix.exs doesn't look right: #{text}\nSee https://github.com/bryanstearns/mix_deps_add#the-rules-for-your-deps0-function for details"
    else
      Mix.raise "Something went wrong; this might help: \"#{inspect parsing_error}\""
    end
  end
end
