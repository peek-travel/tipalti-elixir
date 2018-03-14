defmodule Tipalti.API.SOAP.RequestBuilder do
  import Tipalti.Config
  import XmlBuilder

  def build(root_name, children, key_parts) do
    now = timestamp()
    key = build_key(now, key_parts)
    children = filter_nils([{:payerName, payer()}, {:timestamp, now}, {:key, key} | children])

    doc =
      document(
        "soap12:Envelope",
        %{
          "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
          "xmlns:xsd": "http://www.w3.org/2001/XMLSchema",
          "xmlns:soap12": "http://www.w3.org/2003/05/soap-envelope"
        },
        [element("soap12:Body", [element(root_name, %{xmlns: "http://Tipalti.org/"}, children)])]
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

  defp build_key_part({type, value}, _) do
    # TODO: fix this
    {:ok, part} = format_eat(type, value)
    part
  end

  defp build_key_part(value, _), do: value

  defp format_eat(:string, string) when is_binary(string), do: {:ok, string}
  defp format_eat(:float, float) when is_float(float) or is_integer(float), do: {:ok, float |> trunc() |> to_string()}
  defp format_eat(type, value), do: {:error, {:invalid_eat_value, type, value}}

  defp filter_nils(elements) do
    elements
    |> Enum.reduce([], &do_filter_nils/2)
    |> Enum.reverse()
  end

  defp do_filter_nils({_, nil}, acc), do: acc

  defp do_filter_nils({key, children}, acc) when is_list(children) do
    [{key, children |> Enum.reduce([], &do_filter_nils/2) |> Enum.reverse()} | acc]
  end

  defp do_filter_nils(el, acc), do: [el | acc]
end
