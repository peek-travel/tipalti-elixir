defmodule BodyReader do
  alias Plug.Conn

  @callback read_body(Conn.t(), Keyword.t()) ::
              {:ok, binary(), Conn.t()} | {:more, binary(), Conn.t()} | {:error, term()}
end
