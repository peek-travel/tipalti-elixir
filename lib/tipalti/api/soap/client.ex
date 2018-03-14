defmodule Tipalti.API.SOAP.Client do
  use Tesla

  import Tipalti.Config

  alias Tipalti.API.SOAP.{ResponseParser, RequestBuilder}

  adapter :hackney

  plug Tesla.Middleware.Headers, %{"Content-Type" => "application/soap+xml; charset=utf-8"}

  def run(base_urls, function, params, opts \\ []) do
    with {:ok, payload} <- RequestBuilder.build(function.name, function.request, params, opts) do
      base_urls[mode()]
      |> post(payload)
      |> parse_response(function.response)
    end
  end

  defp parse_response(%Tesla.Env{status: 200, body: body}, {root_path, paths}) do
    ResponseParser.parse(body, root_path, paths)
  end

  defp parse_response(%Tesla.Env{status: status}, _) do
    {:error, {:bad_http_response, status}}
  end
end
