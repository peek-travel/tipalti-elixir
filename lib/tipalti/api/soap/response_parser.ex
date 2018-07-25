defmodule Tipalti.API.SOAP.ResponseParser do
  @moduledoc false

  import SweetXml

  def parse(body, root_path, :empty, response_opts) do
    with :ok <- is_ok?(body, root_path, response_opts) do
      :ok
    end
  end

  def parse(body, root_path, %SweetXpath{} = path, response_opts) do
    document = xpath(body, ~x"/"e)

    with :ok <- is_ok?(document, root_path, response_opts) do
      element = xpath(document, root_path)
      {:ok, xpath(element, path)}
    end
  end

  def parse(body, root_path, [%SweetXpath{} = path | mapping], response_opts) do
    document = xpath(body, ~x"/"e)

    with :ok <- is_ok?(document, root_path, response_opts) do
      element = xpath(document, root_path)
      {:ok, xpath(element, path, mapping)}
    end
  end

  def parse(body, root_path, mapping, response_opts) do
    document = xpath(body, ~x"/"e)

    with :ok <- is_ok?(document, root_path, response_opts) do
      {:ok, xpath(document, root_path, mapping)}
    end
  end

  def parse_without_errors(body, root_path, [path | mapping]) do
    document = xpath(body, ~x"/"e)
    element = xpath(document, root_path)

    xpath(element, path, mapping)
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
