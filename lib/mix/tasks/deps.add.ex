defmodule Mix.Tasks.Deps.Add do
  use Mix.Task
  @shortdoc "Add a new dependency to mix.exs"

  @mix_exs_parsing_errors %{
    no_deps: "deps/0 function not found.",
    ambiguous_deps: "looks like there's more than one deps/0 function?",
    no_deps_end: "end of deps/0 function not found.",
    unparsable_deps: "found the deps/0 function, but couldn't figure out its content."
  }

  def run([package_name]) when is_binary(package_name) do
    (with {:ok, version} <- PackageVersion.current(package_name),
         :ok <- MixExsEditor.add(package_name, version),
      do: {:ok, package_name, version})
    |> handle_result
  end
  def run(_) do
    IO.puts("Usage: mix deps.add PACKAGE_NAME")
    System.halt(2)
  end

  defp handle_result({:ok, package_name, version}) do
    IO.puts("#{inspect package_name} #{version} added")
  end
  defp handle_result({:error, :name_conflict}) do
    IO.puts("Oops: that package is already a dependency; mix.exs unchanged.")
    System.halt(1)
  end
  defp handle_result({:error, :notfound}) do
    IO.puts("Oops: https://hex.pm/ doesn't seem to have a package with that name.")
    System.halt(1)
  end
  defp handle_result({:error, error}) do
    text = Map.get(@mix_exs_parsing_errors, error, nil)
    if text do
      IO.puts("Oops: mix.exs doesn't look right: #{text}\nSee https://github.com/bryanstearns/mix_deps_add/master/README.md#restrictions for details")
    else
      IO.puts("Something went wrong; this might help: \"#{inspect error}\"")
    end
    System.halt(1)
  end
end
