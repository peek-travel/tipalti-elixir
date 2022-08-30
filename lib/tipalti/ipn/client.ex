defmodule Tipalti.IPN.Client do
  @moduledoc false

  use Tesla
  import Tipalti.Config
  require Logger
  alias Tipalti.RequestError

  defmodule Behavior do
    @moduledoc false

    @callback ack(String.t()) :: :ok | {:error, RequestError.t() | :bad_ipn}
  end

  # NOTE: the `client_recv_timeout` is configurable, but set at compile time
  adapter Tesla.Adapter.Hackney, recv_timeout: Application.get_env(:tipalti, :client_recv_timeout, 60_000)

  plug Tesla.Middleware.Headers, [{"Content-Type", "application/x-www-form-urlencoded"}]
  plug Tesla.Middleware.Telemetry

  @url [
    sandbox: "https://console.sandbox.tipalti.com/notif/ipn.aspx",
    production: "https://console.tipalti.com/notif/ipn.aspx"
  ]

  @spec ack(String.t()) :: :ok | {:error, RequestError.t() | :bad_ipn}
  def ack(payload) do
    url = @url[mode()]
    log_request(url, payload)

    case post(url, payload) do
      {:ok, env = %Tesla.Env{status: 200, body: status}} ->
        log_response(env)

        case status do
          "VERIFIED" -> :ok
          "INVALID" -> {:error, :bad_ipn}
        end

      {:ok, env = %Tesla.Env{status: status}} ->
        log_response(env)
        {:error, {:bad_http_response, status}}

      {:error, reason} ->
        :ok = Logger.error(fn -> "[Tipalti IPN] request failed: " <> inspect(reason) end)
        {:error, {:request_failed, reason}}
    end
  end

  defp log_request(url, payload) do
    :ok =
      Logger.debug(fn ->
        """
        [Tipalti IPN] ->> sending event acknowledgement to #{url}
        #{payload}
        """
      end)
  end

  defp log_response(env) do
    :ok =
      Logger.debug(fn ->
        """
        [Tipalti IPN] <<- received #{env.status}
        #{env.body}
        """
      end)
  end
end
