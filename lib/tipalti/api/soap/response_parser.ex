defmodule Tipalti.API.SOAP.ResponseParser do
  import SweetXml

  @error_paths [error_code: ~x"./errorCode/text()"s, error_message: ~x"./errorMessage/text()"s]

  def parse(body, root_path, paths) do
    document = xpath(body, ~x"/"e)

    with :ok <- is_ok?(document, root_path) do
      {:ok, xpath(document, root_path, paths)}
    end
  end

  defp is_ok?(document, root_path) do
    case xpath(document, root_path, @error_paths) do
      %{error_code: "OK"} ->
        :ok

      error ->
        {:error, error}
    end
  end
end
