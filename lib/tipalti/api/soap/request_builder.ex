defmodule Tipalti.API.SOAP.RequestBuilder do
  import Tipalti.Config

  def build(name, fields, params, opts) do
    now = timestamp()

    with {:ok, key} <- build_key(now, fields, params, opts),
         {:ok, formatted_params} <- format_params(params, fields) do
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

  defp format_params(params, fields, acc \\ [])

  defp format_params(_, [], acc), do: {:ok, acc |> Enum.reverse() |> Enum.join("\n      ")}

  defp format_params(params, [{key, {required?, type, name}} | rest], acc) do
    case params[key] do
      nil ->
        if required? == :required do
          {:error, {:missing_required_param, key}}
        else
          format_params(params, rest, ["<#{name} xsi:nil=\"true\" />" | acc])
        end

      value ->
        with {:ok, formatted_value} <- format_param(value, {type, name}) do
          format_params(params, rest, [formatted_value | acc])
        end
    end
  end

  defp format_param(value, {type, name}) when type in [:string, :float, :boolean],
    do: {:ok, "<#{name}>#{value}</#{name}>"}

  defp format_param(_, {type, name}), do: {:error, {:invalid_param_type, type, name}}

  defp build_key(timestamp, fields, params, opts) do
    with {:ok, eat} <- get_eat(params, fields, opts[:eat]) do
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

  defp get_eat(params, fields, field) do
    case fields[field] do
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
