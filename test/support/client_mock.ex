defmodule ClientMock do
  require Logger

  files = Path.wildcard("./test/requests/*_req.xml")

  for file <- files do
    basename = Path.basename(file, "_req.xml")
    req = file |> File.read!() |> String.trim_trailing()
    resp = File.read!("./test/requests/#{basename}_resp.xml")

    def send(_, unquote(req)), do: {:ok, unquote(resp)}
  end

  def send(_, payload) do
    message = """
    Un-mocked payload received. Create a file in ./test/requests with the <filename>_req.xml suffix containing this payload:
    #{payload}
    ...and a corresponding response payload in <filename>_resp.xml.
    """

    Logger.error(message)

    raise "Un-mocked payload received"
  end
end
