defmodule PackageVersion do
  def current(name) do
    name
    |> package_info
    |> Poison.decode!
    |> Map.get("releases")
    |> latest_release
    |> Map.get("version")
  end

  defp package_info(name) do
    ~s"""
    {
      "releases": [
        { "version": "0.0.2" },
        { "version": "0.0.3" },
        { "version": "0.0.1" },
        { "version": "0.0.3-alpha.2" }
      ]
    }
  """
  end

  defp latest_release(releases) do
    releases
    |> Enum.sort(fn a, b -> Version.compare(b["version"], a["version"]) != :gt end)
    |> hd
  end
end
