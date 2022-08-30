defmodule Tipalti.API.SOAP.Client do
  @moduledoc false

  use Tesla
  import Tipalti.Config
  require Logger
  alias Tipalti.RequestError

  # NOTE: the `client_recv_timeout` is configurable, but set at compile time
  adapter Tesla.Adapter.Hackney, recv_timeout: Application.get_env(:tipalti, :client_recv_timeout, 60_000)

  plug Tesla.Middleware.Headers, [{"Content-Type", "application/soap+xml; charset=utf-8"}]
  plug Tesla.Middleware.Telemetry

  @spec send(Keyword.t(), String.t()) :: {:ok, String.t()} | {:error, RequestError.t()}
  def send(base_urls, payload) do
    url = base_urls[mode()]
    log_request(url, payload)

    case post(url, payload) do
      {:ok, env = %Tesla.Env{status: 200, body: body}} ->
        log_response(env)
        {:ok, body}

      {:ok, env = %Tesla.Env{status: status}} ->
        log_response(env)
        {:error, {:bad_http_response, status}}

      {:error, reason} ->
        :ok = Logger.error(fn -> "[Tipalti] request failed: " <> inspect(reason) end)
        {:error, {:request_failed, reason}}
    end
  end

  defp log_request(url, payload) do
    :ok =
      Logger.debug(fn ->
        """
        [Tipalti] ->> sending payload to #{url}
        #{payload}
        """
      end)
  end

  defp log_response(env) do
    :ok =
      Logger.debug(fn ->
        charlist_body = env.body |> String.replace("\"", "\\\"") |> to_charlist()

        pretty_printed_body =
          try do
            ('echo "' ++ charlist_body ++ '" | xmllint --format -') |> :os.cmd() |> to_string()
          rescue
            _ -> env.body
          end

        """
        [Tipalti] <<- received #{env.status}
        #{pretty_printed_body}
        """
      end)
  end
end
