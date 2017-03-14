defmodule PackageVersion do
  def current(name, hex_client \\ HexClient) do
    with {:ok, info} <- hex_client.package_info(name),
         latest <- latest_release(info),
      do: {:ok, latest}
  end

  defp latest_release(package_info) do
    package_info
    |> Map.get("releases")
    |> Enum.sort(fn a, b -> Version.compare(b["version"], a["version"]) != :gt end)
    |> hd
    |> Map.get("version")
  end
end
