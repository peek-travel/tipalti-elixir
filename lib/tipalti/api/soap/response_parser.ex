defmodule Tipalti.API.SOAP.ResponseParser do
  @moduledoc false

  import SweetXml

  def parse(body, root_path, :empty, response_opts) do
    with :ok <- is_ok?(body, root_path, response_opts) do
      {:ok, :ok}
    end
  end

  def parse(body, root_path, paths, response_opts) do
    document = xpath(body, ~x"/"e)

    with :ok <- is_ok?(document, root_path, response_opts) do
      {:ok, xpath(document, root_path, paths)}
    end
  end

  def parse_without_errors(body, root_path, paths) do
    document = xpath(body, ~x"/"e)

    xpath(document, root_path, paths)
  end

  defp is_ok?(document, root_path, response_opts) do
    ok_code = response_opts[:ok_code]
    error_paths = response_opts[:error_paths]

    case xpath(document, root_path, error_paths) do
      %{error_code: ^ok_code} ->
        :ok

      error ->
        {:error, error}
    end
  end
end
