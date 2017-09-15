defmodule MixDepsAdd.PackageVersion do
  alias MixDepsAdd.HexClient

  def current(name_or_path, hex_client \\ HexClient) do
    case Path.split(name_or_path) do
      [^name_or_path | []] ->
        hex_version_for(name_or_path, hex_client)
      _ ->
        local_path_and_name_for(name_or_path)
    end
  end

  defp hex_version_for(name, hex_client) do
    with {:ok, info} <- hex_client.package_info(name),
         latest <- latest_release(info),
      do: {:versioned, latest}
  end

  defp local_path_and_name_for(path) do
    try do
      app_name = Mix.Project.in_project(String.to_atom(path), path, fn module ->
        module.project[:app] |> to_string
      end)
      {:relative, app_name, path}
    rescue
      File.Error -> {:error, :nonexistant}
    end
  end

  defp latest_release(package_info) do
    package_info
    |> Map.get("releases")
    |> Enum.sort(fn a, b -> Version.compare(b["version"], a["version"]) != :gt end)
    |> hd
    |> Map.get("version")
  end
end
