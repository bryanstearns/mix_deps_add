defmodule MixExsEditor do
  @deps_start_regex ~r/\A\s*defp deps do\z/
  @deps_end_regex ~r/\A\s*end\z/
  @dep_regex ~r/\A\s+\[?\{(.*)\}[\],]?\z/
  @square_brackets_regex ~r/\A\s+[\[\]]{1,2}\z/

  def add(name, version, filename \\ "mix.exs") do
    filename
    |> read
    |> ensure_unique_name(name)
    |> insert(name, version)
    |> write
  end

  def read(filename \\ "mix.exs") do
    File.read!(filename)
    |> String.split("\n")
    |> parse(filename)
  end

  def insert({:error, _} = result, _name, _version), do: result
  def insert({before_stuff, deps, after_stuff, filename}, name, version) do
    deps = [":#{name}, \"~> #{version}\"" | deps]
    |> Enum.sort
    |> Enum.map(&("{#{&1}}"))
    |> Enum.join(",\n      ")

    content = [before_stuff, "    [\n      #{deps}\n    ]", after_stuff]
    |> Enum.join("\n")
    {content, filename}
  end

  def ensure_unique_name({:error, _} = result, _name), do: result
  def ensure_unique_name({_, deps, _, _} = parsed, name) do
    if Enum.any?(deps, &(String.starts_with?(&1, ":" <> name <> ","))) do
      {:error, :name_conflict}
    else
      parsed
    end
  end

  def write({:error, _} = result), do: result
  def write({content, filename}) do
    File.write!(filename, content)
  end

  defp parse(lines, filename) do
    with dsi when is_number(dsi) <- deps_start_index(lines),
         dei when is_number(dei) <- deps_end_index(lines, dsi),
         deps_lines <-
           Enum.slice(lines, (dsi + 1)..(dei - 1)),
         deps when is_list(deps) <-
           parse_deps(deps_lines),
      do: {Enum.slice(lines, 0..dsi) |> Enum.join("\n"),
           deps,
           Enum.slice(lines, dei..-1) |> Enum.join("\n"),
           filename}
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
    || {:error, :no_deps_end}
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
