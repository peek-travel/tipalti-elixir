defmodule Tipalti.API.SOAP.Client do
  @moduledoc false

  use Tesla

  import Tipalti.Config

  adapter Tesla.Adapter.Hackney

  plug Tesla.Middleware.Headers, [{"Content-Type", "application/soap+xml; charset=utf-8"}]

  def send(base_urls, payload) do
    case base_urls[mode()] |> post(payload) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status}} ->
        {:error, {:bad_http_response, status}}

      {:error, reason} ->
        {:error, {:request_failes, reason}}
    end
  end
end
