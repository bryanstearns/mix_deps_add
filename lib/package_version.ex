defmodule PackageVersion do

  def current(name, http_library \\ HTTPoison) do
    with {:ok, raw} <- raw_package_info(name, http_library),
         latest <- latest_release(raw),
      do: {:ok, latest}
  end

  def raw_package_info(name, http_library) do
    with url <- package_info_url(name),
         response <- http_library.get(url),
         {:ok, raw_body} <- process_http_response(response),
      do: {:ok, raw_body}
  end

  defp process_http_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.decode!(body)}
  end
  defp process_http_response({:ok, %{status_code: 404}}), do: {:error, :notfound}
  defp process_http_response(_), do: {:error, :unknown}

  defp package_info_url(name) do
    "https://hex.pm/api/packages/#{name}"
  end

  defp latest_release(raw_package_info) do
    raw_package_info
    |> Map.get("releases")
    |> Enum.sort(fn a, b -> Version.compare(b["version"], a["version"]) != :gt end)
    |> hd
    |> Map.get("version")
  end
end
