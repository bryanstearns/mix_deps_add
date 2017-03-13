defmodule Mix.Tasks.Deps.Add do
  use Mix.Task
  @shortdoc "Add a new dependency to mix.exs"

  def run(package_name) do
    HTTPoison.start
    with {:ok, version} <- PackageVersion.current(package_name),
         :ok <- MixExsEditor.add(package_name, version),
      do: {:ok, package_name, version}
    |> handle_result
  end

  defp handle_result({:ok, package_name, version}) do
    IO.puts("#{inspect package_name} #{version} added")
  end

  defp handle_result({:error, :name_conflict}) do
    IO.puts("Oops: that package is already a dependency; mix.exs unchanged.")
  end

  defp handle_result({:error, error}) do
    message = case error do
      :no_deps ->
        "deps/0 function not found."
      :ambiguous_deps ->
        "looks like there's more than one deps/0 function?"
      :no_deps_end ->
        "end of deps/0 function not found."
      :unparsable_deps ->
        "found the deps/0 function, but couldn't figure out its content."
      _ ->
        "unknown error!"
    end
    IO.puts("Oops: mix.exs doesn't look right: #{message}\nSee https://github.com/bryanstearns/mix_deps_add/master/README.md#restrictions for details")
  end
end
