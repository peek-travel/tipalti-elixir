defmodule Tipalti.IPN.Router do
  @moduledoc """
  A router builder for handling incoming Tipalti Instant Payment Notifications (IPN).

  ## Usage

      defmodule MyApp.Tipalti.IPNRouter do
        use Tipalti.IPN.Router, scope: "/events"

        on "bill_updated", MyApp.Tipalti.OnBillUpdated
      end
  """

  require Logger

  import Plug.Conn

  alias Plug.Conn
  alias Tipalti.IPN

  @doc false
  defmacro __using__(opts) do
    scope = Keyword.get(opts, :scope)

    quote do
      use Plug.Router

      # @behaviour Tipalti.IPN.Router

      @scope unquote(scope)

      plug :match
      plug :dispatch

      import Tipalti.IPN.Router, only: [on: 2, do_call: 2]

      @before_compile Tipalti.IPN.Router
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      import Plug.Router

      match(_, do: var!(conn))

      import Plug.Router, only: []
    end
  end

  @doc """
  Adds a listening route for incoming POST events.

  The route is built from the `:scope` option given to the router, and the event name.

  ## Example

      defmodule MyApp.Tipalti.IPNRouter do
        use Tipalti.IPN.Router, scope: "/events"

        on "bill_updated", MyApp.Tipalti.OnBillUpdated
      end

  The above would create a new route responding to POST requests at `/events/bill_updated`. The module given must define
  a `call` event that receives the event as a map of string key value pairs, and return `:ok` to signal it successfully
  processed the event.
  """
  defmacro on(event, module) do
    quote do
      path = [@scope, unquote(event)] |> Enum.reject(&is_nil/1) |> Enum.join("/")

      post path do
        do_call(var!(conn), unquote(module))
      end
    end
  end

  @doc false
  def do_call(conn, module) do
    body_reader = Application.get_env(:tipalti, :ipn_body_reader, Conn)

    case body_reader.read_body(conn, []) do
      {:ok, body, conn} ->
        event_params = Conn.Query.decode(body)

        case handle_event(module, event_params) do
          :ok ->
            ack!(body)

            conn
            |> send_resp(200, "OK")
            |> halt()

          error ->
            raise "Unable to process IPN: #{inspect(error)}"
        end

      {:more, _data, _conn} ->
        raise Plug.BadRequestError

      {:error, :timeout} ->
        raise Plug.TimeoutError

      {:error, _} ->
        raise Plug.BadRequestError
    end
  end

  defp handle_event(module, %{"type" => type} = event) when type in ~w(
    bill_updated
    completed
    deferred
    error
    payee_compliance_document_closed
    payee_compliance_document_request
    payee_compliance_screening_result
    payee_details_changed
    payee_invoices_sync_now
    payer_fees
    payment_cancelled
    payment_submitted
    payments_group_approved
    payments_group_declined
  ) do
    module.call(event)
  end

  defp handle_event(_, event) do
    Logger.warn("[Tipalti IPN] Invalid event received: #{inspect(event)}")

    :ok
  end

  defp ack!(body) do
    client = Application.get_env(:tipalti, :ipn_client_module, IPN.Client)

    case client.ack(body) do
      :ok ->
        :ok

      {:error, :bad_ipn} ->
        :ok = Logger.warn("[Tipalti IPN] Invalid IPN received")
        :ok

      error ->
        raise "Unable to ack IPN: #{inspect(error)}"
    end
  end
end
