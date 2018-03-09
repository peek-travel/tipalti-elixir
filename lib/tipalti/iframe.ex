defmodule Tipalti.IFrame do
  @moduledoc false
  import Tipalti.Config

  @doc false
  @spec build_url(map(), map(), Tipalti.IFrame.SetupProcess.options()) :: URI.t()
  def build_url(base_urls, params, opts \\ []) do
    basic_query_string =
      params
      |> query_params(opts)
      |> URI.encode_query()

    hash = build_hashkey(basic_query_string)

    full_query_string = basic_query_string <> "&hashkey=" <> hash

    URI.parse(base_urls[mode()] <> full_query_string)
  end

  @doc false
  defp query_params(params, opts) do
    params
    |> Enum.reduce(%{}, &format_param(&1, &2, opts))
    |> Map.merge(%{"payer" => payer(), "ts" => timestamp()})
  end

  @doc false
  defp format_param({key, value}, params, opts) do
    force = opts[:force] || []
    read_only = opts[:read_only] || []

    cond do
      is_nil(value) ->
        params

      key in force ->
        Map.put(params, "force" <> String.capitalize("#{key}"), value)

      key in read_only ->
        Map.merge(params, %{"#{key}" => value, ("#{key}" <> "SetReadOnly") => "TRUE"})

      :else ->
        Map.put(params, "#{key}", value)
    end
  end
end
