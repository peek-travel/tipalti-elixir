defmodule Tipalti.API.SOAP.Client do
  use Tesla

  import Tipalti.Config

  alias Tipalti.API.SOAP.{ResponseParser, RequestBuilder}

  adapter :hackney

  plug Tesla.Middleware.Headers, %{"Content-Type" => "application/soap+xml; charset=utf-8"}

  def run(base_urls, function_name, request, key_parts, response_paths) do
    # TODO: add back with {:ok, payload} <- ...
    payload = RequestBuilder.build(function_name, request, key_parts)

    base_urls[mode()]
    |> post(payload)
    |> parse_response(response_paths)
  end

  defp parse_response(%Tesla.Env{status: 200, body: body}, {root_path, paths}),
    do: ResponseParser.parse(body, root_path, paths)

  defp parse_response(%Tesla.Env{status: status}, _), do: {:error, {:bad_http_response, status}}
end
