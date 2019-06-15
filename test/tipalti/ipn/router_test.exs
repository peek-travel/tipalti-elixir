defmodule Tipalti.IPN.RouterTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  import Mox

  defmodule SuccessfulHandler do
    def call(event) do
      assert event == %{"bill_refcode" => "pi_12345", "bill_status" => "Paid", "type" => "bill_updated"}
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

  @good_event "type=bill_updated&bill_refcode=pi_12345&bill_status=Paid"
  @weird_event "type=bills&bill_refcode=pi_12345&bill_status=Paid"
  @bad_event "type=foo"

  test "handles successful calls" do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", @good_event)

    assert capture_log(fn ->
             conn = SuccessfulRouter.call(conn, [])
             assert conn.resp_body == "OK"
             assert conn.status == 200
           end) =~ "Event received"
  end

  test ~s(translates events with type "bills" to type "bill_update") do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", @weird_event)

    assert capture_log(fn ->
             conn = SuccessfulRouter.call(conn, [])
             assert conn.resp_body == "OK"
             assert conn.status == 200
           end) =~ "Event received"
  end

  test "handles errors from the handler" do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", @good_event)

    assert_raise Plug.Conn.WrapperError, "** (RuntimeError) Unable to process IPN: {:error, :something_bad}", fn ->
      assert capture_log(fn ->
               FailingRouter.call(conn, [])
             end) =~ "Event received"
    end
  end

  test "raises if it can't ack the notification" do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> {:error, :unknown} end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", @good_event)

    assert_raise Plug.Conn.WrapperError, "** (RuntimeError) Unable to ack IPN: {:error, :unknown}", fn ->
      assert capture_log(fn ->
               SuccessfulRouter.call(conn, [])
             end) =~ "Event received"
    end
  end

  test "logs a warning if the notification couldn't be verified" do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> {:error, :bad_ipn} end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", @good_event)

    assert capture_log(fn ->
             conn = SuccessfulRouter.call(conn, [])

             assert conn.resp_body == "OK"
             assert conn.status == 200
           end) =~ "Invalid IPN received"
  end

  test "logs a warning if an unknown event type is received" do
    expect(BodyReaderMock, :read_body, fn conn, opts -> Plug.Conn.read_body(conn, opts) end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", @bad_event)

    assert capture_log(fn ->
             conn = SuccessfulRouter.call(conn, [])

             assert conn.resp_body == "OK"
             assert conn.status == 200
           end) =~ "Invalid event received"
  end

  test "raises BadRequestError on bad body" do
    expect(BodyReaderMock, :read_body, fn _conn, _opts -> {:error, :invalid_body} end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", @good_event)

    assert_raise Plug.Conn.WrapperError,
                 "** (Plug.BadRequestError) could not process the request due to client error",
                 fn ->
                   SuccessfulRouter.call(conn, [])
                 end
  end

  test "raises BadRequestError on too large body" do
    expect(BodyReaderMock, :read_body, fn conn, _opts -> {:more, "", conn} end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", @good_event)

    assert_raise Plug.Conn.WrapperError,
                 "** (Plug.BadRequestError) could not process the request due to client error",
                 fn ->
                   SuccessfulRouter.call(conn, [])
                 end
  end

  test "raises TimeoutError on body read timeout" do
    expect(BodyReaderMock, :read_body, fn _conn, _opts -> {:error, :timeout} end)
    expect(IPNClientMock, :ack, fn _ -> :ok end)

    conn = Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :post, "/events/bill_updated", @good_event)

    assert_raise Plug.Conn.WrapperError, "** (Plug.TimeoutError) timeout while waiting for request data", fn ->
      SuccessfulRouter.call(conn, [])
    end
  end
end
