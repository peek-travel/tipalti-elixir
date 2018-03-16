defmodule Tipalti.API do
  defmacro __using__(opts) do
    quote do
      alias Tipalti.API.SOAP.{Client, RequestBuilder, ResponseParser}
      import Tipalti.API

      def run(function_name, request, key_parts, {root_path, paths}) do
        payload = RequestBuilder.build(function_name, request, key_parts)

        with {:ok, body} <- Client.send(unquote(opts)[:url], payload) do
          ResponseParser.parse(body, root_path, paths, unquote(opts)[:standard_response])
        end
      end
    end
  end

  def get_required_opt(opts, key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} ->
        {:ok, value}

      :error ->
        {:error, {:missing_required_option, key}}
    end
  end
end
