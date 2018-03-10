defmodule Tipalti.API do
  use Tesla

  import Tipalti.Config
  import Record, only: [defrecord: 2, extract: 2]

  defrecord :xml_element, extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  defrecord :xml_text, extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  adapter :hackney

  plug Tesla.Middleware.Headers, %{"Content-Type" => "application/soap+xml; charset=utf-8"}

  def run(base_urls, function, params, opts \\ []) do
    with {:ok, payload} <- build_soap_payload(function.name, function.request, params, opts) do
      base_urls[mode()]
      |> post(payload)
      |> parse_response(function.response)
    end
  end

  defp parse_response(%Tesla.Env{status: 200, body: body}, fields) do
    document = parse_document(body)

    with [object] <- :xmerl_xpath.string('/soap:Envelope/soap:Body/*/*', document) do
      parse_object(object, fields)
    else
      _ ->
        {:error, {:unexpected_response_body, body}}
    end
  end

  defp parse_response(%Tesla.Env{status: status}, _), do: {:error, {:bad_http_response, status}}

  defp parse_object(object, fields) do
    with :ok <- is_ok?(object) do
      build_object(Enum.to_list(fields), object, %{})
    end
  end

  defp build_object([], _object, acc), do: {:ok, acc}

  defp build_object([{field, {type, path}} | rest], object, acc) do
    with {:ok, value} <- get_content(object, '/*/' ++ to_charlist(path)) do
      build_object(rest, object, Map.put(acc, field, format_value(value, type)))
    end
  end

  defp is_ok?(object) do
    with [element] <- :xmerl_xpath.string('/*/errorCode', object),
         [content] <- xml_element(element, :content),
         'OK' <- xml_text(content, :value) do
      :ok
    else
      _ ->
        with {:ok, error_code} <- get_content(object, '/*/errorCode'),
             {:ok, error_message} <- get_content(object, '/*/errorMessage') do
          {:error, {:error_response, %{error_message: error_message, error_code: error_code}}}
        end
    end
  end

  defp get_content(object, path) do
    with [element] <- :xmerl_xpath.string(path, object),
         [content] <- xml_element(element, :content) do
      {:ok, content |> xml_text(:value) |> to_string()}
    else
      _ ->
        {:error, {:invalid_response_content, to_string(path)}}
    end
  end

  defp format_value(string, :string), do: string

  defp parse_document(body) do
    {doc, _} = body |> to_charlist() |> :xmerl_scan.string()
    doc
  end

  defp build_soap_payload(name, request, params, opts) do
    now = timestamp()

    with {:ok, key} <- build_key(now, request, params, opts),
         {:ok, formatted_params} <- format_params(params, request) do
      payload = """
      <?xml version="1.0" encoding="utf-8"?>
      <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:xsd="http://www.w3.org/2001/XMLSchema"
          xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
        <soap12:Body>
          <#{name} xmlns="http://Tipalti.org/">
            <payerName>#{payer()}</payerName>
            <timestamp>#{now}</timestamp>
            <key>#{key}</key>
            #{formatted_params}
          </#{name}>
        </soap12:Body>
      </soap12:Envelope>
      """

      {:ok, payload}
    end
  end

  defp format_params(params, request) do
    # TODO: use `request` to format correctly if needed
    params =
      request
      |> Enum.map(fn {key, field} ->
        format_param(params[key], field)
      end)
      |> Enum.join()

    {:ok, params}
  end

  defp format_param(value, {:string, name}), do: "<#{name}>#{value}</#{name}>"
  defp format_param(value, {:float, name}), do: "<#{name}>#{value}</#{name}>"
  # TODO: error cases

  defp build_key(timestamp, request, params, opts) do
    with {:ok, eat} <- get_eat(params, request, opts[:eat]) do
      key =
        [
          payer(),
          opts[:idap],
          timestamp,
          eat
        ]
        |> Enum.join()
        |> build_hashkey()

      {:ok, key}
    end
  end

  defp get_eat(_, _, nil), do: {:ok, nil}

  defp get_eat(params, request, field) do
    case request[field] do
      nil ->
        {:error, {:eat_field_definition_missing, field}}

      {type, _name} ->
        case params[field] do
          nil ->
            {:error, {:eat_value_missing, field}}

          eat_value ->
            {:ok, format_eat(type, eat_value)}
        end
    end
  end

  defp format_eat(:string, string), do: string
  defp format_eat(:float, float), do: float |> trunc() |> to_string()
end
