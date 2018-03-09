defmodule Tipalti.API do
  use Tesla

  import Tipalti.Config
  import Record, only: [defrecord: 2, extract: 2]

  defrecord :xml_element, extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  defrecord :xml_text, extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  adapter :hackney

  plug Tesla.Middleware.Headers, %{"Content-Type" => "application/soap+xml; charset=utf-8"}

  def run(base_urls, function, params, opts \\ []) do
    base_urls[mode()]
    |> post(build_soap_body(function, params, opts))
    |> parse_response(function.response)
  end

  defp parse_response(%Tesla.Env{status: 200, body: body}, %{fields: fields}) do
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
          {:error, %{error_message: error_message, error_code: error_code}}
        end
    end
  end

  defp get_content(object, path) do
    with [element] <- :xmerl_xpath.string(path, object),
         [content] <- xml_element(element, :content) do
      {:ok, content |> xml_text(:value) |> to_string()}
    else
      _ ->
        {:error, {:invalid_content, to_string(path)}}
    end
  end

  defp format_value(string, :string), do: string

  defp parse_document(body) do
    {doc, _} = body |> to_charlist() |> :xmerl_scan.string()
    doc
  end

  defp build_soap_body(function, params, opts) do
    now = timestamp()
    key = build_key(now, opts)
    formatted_params = format_params(params, function.request)

    """
    <?xml version="1.0" encoding="utf-8"?>
    <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
      <soap12:Body>
        <#{function.name} xmlns="http://Tipalti.org/">
          <payerName>#{payer()}</payerName>
          <timestamp>#{now}</timestamp>
          <key>#{key}</key>
          #{formatted_params}
        </#{function.name}>
      </soap12:Body>
    </soap12:Envelope>
    """
  end

  defp format_params(params, request) do
    # TODO: use `request` to format correctly if needed
    request.fields
    |> Enum.map(fn {key, field} ->
      format_param(params[key], field)
    end)
    |> Enum.join()
  end

  defp format_param(value, {:string, name}), do: "<#{name}>#{value}</#{name}>"
  defp format_param(value, {:float, name}), do: "<#{name}>#{value}</#{name}>"
  # TODO: error cases

  defp build_key(timestamp, opts) do
    [
      payer(),
      opts[:idap],
      timestamp,
      format_eat(opts[:eat])
    ]
    |> Enum.join()
    |> build_hashkey()
  end

  defp format_eat(nil), do: nil
  defp format_eat({:string, string}), do: string
  defp format_eat({:float, float}), do: float |> trunc() |> to_string()
end
