defmodule Tipalti.API.SOAP.Client do
  @moduledoc false

  use Tesla
  import Tipalti.Config
  require Logger

  adapter :hackney, recv_timeout: 60_000

  plug Tesla.Middleware.Headers, %{"Content-Type" => "application/soap+xml; charset=utf-8"}

  def send(base_urls, payload) do
    url = base_urls[mode()]

    Logger.debug(fn ->
      """
      [Tipalti] ->> sending payload to #{url}
      #{payload}
      """
    end)

    env = post(url, payload)

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

    env |> parse_response()
  end

  defp parse_response(%Tesla.Env{status: 200, body: body}), do: {:ok, body}

  defp parse_response(%Tesla.Env{status: status}), do: {:error, {:bad_http_response, status}}
end
