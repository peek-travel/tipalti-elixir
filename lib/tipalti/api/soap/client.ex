defmodule Tipalti.API.SOAP.Client do
  use Tesla

  import Tipalti.Config

  adapter :hackney

  plug Tesla.Middleware.Headers, %{"Content-Type" => "application/soap+xml; charset=utf-8"}

  def send(base_urls, payload) do
    base_urls[mode()]
    |> post(payload)
    |> parse_response()
  end

  defp parse_response(%Tesla.Env{status: 200, body: body}), do: {:ok, body}

  defp parse_response(%Tesla.Env{status: status}), do: {:error, {:bad_http_response, status}}
end
