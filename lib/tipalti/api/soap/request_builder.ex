defmodule Tipalti.API.SOAP.RequestBuilder do
  import Tipalti.Config
  import XmlBuilder

  def build(function_name, params, key_parts) do
    now = timestamp()
    key = build_key(now, key_parts)
    params = filter_nils([{:payerName, payer()}, {:timestamp, now}, {:key, key} | params])

    doc =
      document(
        "soap12:Envelope",
        %{
          "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
          "xmlns:xsd": "http://www.w3.org/2001/XMLSchema",
          "xmlns:soap12": "http://www.w3.org/2003/05/soap-envelope"
        },
        [element("soap12:Body", [element(function_name, %{xmlns: "http://Tipalti.org/"}, params)])]
      )

    generate(doc)
  end

  defp build_key(timestamp, key_parts) do
    key_parts
    |> Enum.map(&build_key_part(&1, timestamp))
    |> Enum.join()
    |> build_hashkey()
  end

  defp build_key_part(:payer_name, _), do: payer()
  defp build_key_part(:timestamp, timestamp), do: timestamp

  defp build_key_part({type, value}, _), do: format_eat(type, value)

  defp build_key_part(value, _), do: value

  defp format_eat(:float, float) when is_float(float) or is_integer(float), do: float |> trunc() |> to_string()

  defp filter_nils(elements) do
    elements
    |> Enum.reduce([], &do_filter_nils/2)
    |> Enum.reverse()
  end

  defp do_filter_nils({_, nil}, acc), do: acc

  defp do_filter_nils({key, params}, acc) when is_list(params) do
    [{key, params |> Enum.reduce([], &do_filter_nils/2) |> Enum.reverse()} | acc]
  end

  defp do_filter_nils(el, acc), do: [el | acc]
end
