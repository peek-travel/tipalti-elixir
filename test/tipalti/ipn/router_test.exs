defmodule Tipalti.IPN.RouterTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  import Mox

  defmodule SuccessfulHandler do
    def call(event) do
      assert event == %{"foo" => "bar", "bar" => "baz"}
      :ok
    end
  end

  defmodule FailingHandler do
    def call(_event) do
      {:error, :something_bad}
    end
  end

  defmodule SuccessfulRouter do
    use Tipalti.IPN.Router, scope: "/events"

    on "bill_updated", SuccessfulHandler
  end

  defmodule FailingRouter do
    use Tipalti.IPN.Router, scope: "/events"

    on "bill_updated", FailingHandler
  end

  test "handles successful calls" do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", "foo=bar&bar=baz")
    conn = SuccessfulRouter.call(conn, [])

    assert conn.resp_body == "OK"
    assert conn.status == 200
  end

  test "handles errors from the handler" do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", "foo=bar&bar=baz")

    assert_raise RuntimeError, "Unable to process IPN: {:error, :something_bad}", fn ->
      FailingRouter.call(conn, [])
    end
  end

  test "raises if it can't ack the notification" do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> {:error, :unknown} end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", "foo=bar&bar=baz")

    assert_raise RuntimeError, "Unable to ack IPN: {:error, :unknown}", fn ->
      SuccessfulRouter.call(conn, [])
    end
  end

  test "logs a warning if the notification couldn't be verified" do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> {:error, :bad_ipn} end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", "foo=bar&bar=baz")

    assert capture_log(fn ->
             conn = SuccessfulRouter.call(conn, [])

             assert conn.resp_body == "OK"
             assert conn.status == 200
           end) =~ "[warn]  Invalid IPN received"
  end

  test "raises BadRequestError on bad body" do
    expect(BodyReaderMock, :read_body, fn _conn, _opts -> {:error, :invalid_body} end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", "foo=bar&bar=baz")

    assert_raise Plug.BadRequestError, fn ->
      SuccessfulRouter.call(conn, [])
    end
  end

  test "raises BadRequestError on too large body" do
    expect(BodyReaderMock, :read_body, fn conn, _opts -> {:more, "", conn} end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", "foo=bar&bar=baz")

    assert_raise Plug.BadRequestError, fn ->
      SuccessfulRouter.call(conn, [])
    end
  end

  test "raises TimeoutError on body read timeout" do
    expect(BodyReaderMock, :read_body, fn _conn, _opts -> {:error, :timeout} end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", "foo=bar&bar=baz")

    assert_raise Plug.TimeoutError, fn ->
      SuccessfulRouter.call(conn, [])
    end
  end
end
