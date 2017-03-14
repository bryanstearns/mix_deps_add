defmodule HexClient do
  def package_info(package_name) do
    :inets.start()
    :ssl.start()
    :httpc.request(:get, {to_charlist(package_info_url(package_name)),
                          [{'user-agent', 'mix deps add'},
                           {'accept', 'application/vnd.hex+elixir'}]},
                         [], [])
    |> process_http_response
  end

  defp package_info_url(name) do
    "https://hex.pm/api/packages/#{name}"
  end

  defp process_http_response({:ok, {{_http, 200, _phrase}, _headers, body}}) do
    {body_map, []} = Code.eval_string(body)
    {:ok, body_map}
  end
  defp process_http_response({:ok, {{_http, 404, _phrase}, _headers, _body}}) do
    {:error, :notfound}
  end
  defp process_http_response({:error, _reason} = wtf), do: wtf
end
