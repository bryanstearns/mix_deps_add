defmodule MixExsEditor do
  @deps_start_regex ~r/\A\s*defp deps do\z/
  @deps_end_regex ~r/\A\s*end\z/
  @dep_regex ~r/\A\s+\[?\{(.*)\}[\],]?\z/
  @square_brackets_regex ~r/\A\s+[\[\]]{1,2}\z/

  defstruct results: [], before: "", deps: [], after: "", filename: "mix.exs"

  def read(filename \\ "mix.exs") do
    File.read!(filename)
    |> String.split("\n")
    |> parse(filename)
  end

  def add(%{results: results, deps: deps} = state, name, version) do
    if Enum.any?(deps, &(String.starts_with?(&1, ":" <> name <> ","))) do
      %{state | results: [{:name_conflict, name} | state.results]}
    else
      deps = [":#{name}, \"~> #{version}\"" | deps]
      |> Enum.sort

      %{state | deps: deps, results: [{:ok, name, version} | results]}
    end
  end

  def write(%{results: results, before: before_stuff, deps: deps,
              after: after_stuff, filename: filename}) do
    if success?(results) do
      deps = deps
      |> Enum.map(&("{#{&1}}"))
      |> Enum.join(",\n      ")

      content = [before_stuff, "    [\n      #{deps}\n    ]", after_stuff]
      |> Enum.join("\n")

      File.write!(filename, content)
      :ok
    else
      {:error, results}
    end
  end

  def success?(results) do
    Enum.all?(results, fn
      {:ok, _, _} -> true
      _ -> false
    end)
  end

  defp parse(lines, filename) do
    with dsi when is_number(dsi) <- deps_start_index(lines),
         dei when is_number(dei) <- deps_end_index(lines, dsi),
         deps_lines <-
           Enum.slice(lines, (dsi + 1)..(dei - 1)),
         deps when is_list(deps) <- parse_deps(deps_lines)
      do %MixExsEditor{before: Enum.slice(lines, 0..dsi) |> Enum.join("\n"),
                       deps: deps,
                       after: Enum.slice(lines, dei..-1) |> Enum.join("\n"),
                       filename: filename}
      else
        {:error, error} -> %MixExsEditor{results: [error], filename: filename}
      end
  end

  defp deps_start_index(lines) do
    lines
    |> Enum.with_index
    |> Enum.filter(&(Regex.match?(@deps_start_regex, elem(&1, 0))))
    |> Enum.map(fn {_, i} -> i end)
    |> exactly_one(:no_deps, :ambiguous_deps)
  end
  defp exactly_one([x], _, _), do: x
  defp exactly_one([], none_error, _), do: {:error, none_error}
  defp exactly_one(_, _, too_many_error), do: {:error, too_many_error}

  defp deps_end_index(lines, start_index) do
    (with lines <- Enum.slice(lines, start_index..-1),
         end_index when not is_nil(end_index) <-
           Enum.find_index(lines, &(Regex.match?(@deps_end_regex, &1))),
      do: start_index + end_index)
    || {:errors, :no_deps_end}
  end

  defp parse_deps(lines, acc \\ [])
  defp parse_deps([], acc), do: acc
  defp parse_deps([line | rest], acc) do
    cond do
      Regex.match?(@dep_regex, line) -> parse_deps(rest, [parse_dep(line) | acc])
      Regex.match?(@square_brackets_regex, line) -> parse_deps(rest, acc)
      true -> {:error, :unparsable_deps}
    end
  end

  defp parse_dep(line) do
    String.replace(line, @dep_regex, "\\1")
  end
end
