defmodule Tipalti.API do
  use Tesla

  import Tipalti.Config
  import Record, only: [defrecord: 2, extract: 2]

  @xmerl "xmerl/include/xmerl.hrl"
  defrecord :xml_element, extract(:xmlElement, from_lib: @xmerl)
  defrecord :xml_text, extract(:xmlText, from_lib: @xmerl)

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
    with {:ok, value} <- get_content(object, '/*/' ++ to_charlist(path)),
         {:ok, formatted_value} <- format_value(value, type) do
      build_object(rest, object, Map.put(acc, field, formatted_value))
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
        {:ok, nil}
    end
  end

  defp format_value(nil, _), do: {:ok, nil}
  defp format_value(string, :string), do: {:ok, string}
  defp format_value("false", :boolean), do: {:ok, false}
  defp format_value("true", :boolean), do: {:ok, true}
  defp format_value(value, type), do: {:error, {:invalid_response_value, type, value}}

  defp parse_document(body) do
    {doc, _} = body |> to_charlist() |> :xmerl_scan.string()
    doc
  end

  defp build_soap_payload(name, request, params, opts) do
    now = timestamp()

    with {:ok, key} <- build_key(now, request, params, opts),
         {:ok, formatted_params} <- format_params(params, Enum.to_list(request)) do
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

  defp format_params(params, request, acc \\ [])

  defp format_params(_, [], acc), do: {:ok, acc |> Enum.reverse() |> Enum.join()}

  defp format_params(params, [{key, {required?, type, name}} | rest], acc) do
    case params[key] do
      nil ->
        if required? == :required do
          {:error, {:missing_required_param, key}}
        else
          format_params(params, rest, acc)
        end

      value ->
        with {:ok, formatted_value} <- format_param(value, {type, name}) do
          format_params(params, rest, [formatted_value | acc])
        end
    end
  end

  defp format_param(nil, _), do: {:ok, nil}

  defp format_param(value, {type, name}) when type in [:string, :float, :boolean],
    do: {:ok, "<#{name}>#{value}</#{name}>"}

  defp format_param(_, {type, name}), do: {:error, {:invalid_param_type, type, name}}

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

      {_required?, type, _name} ->
        case params[field] do
          nil ->
            {:error, {:eat_value_missing, field}}

          eat_value ->
            with {:ok, formatted_eat} <- format_eat(type, eat_value) do
              {:ok, formatted_eat}
            end
        end
    end
  end

  defp format_eat(:string, string) when is_binary(string), do: {:ok, string}
  defp format_eat(:float, float) when is_float(float) or is_integer(float), do: {:ok, float |> trunc() |> to_string()}
  defp format_eat(type, value), do: {:error, {:invalid_eat_value, type, value}}
end
