defmodule Tipalti do
  @moduledoc """
  Tipalti integration library for Elixir.

  This library contains the following:

  *   `Tipalti.API.Payee` - Payee SOAP API client
  *   `Tipalti.API.Payer` - Payer SOAP API client
  *   `Tipalti.IPN.Router` - Router builder Tipalti Instant Payment Notifications (IPN)
  *   `Tipalti.IFrame.InvoiceHistory` - Invoice History iFrame integration helper
  *   `Tipalti.IFrame.PaymentsHistory` - Payments History iFrame integration helper
  *   `Tipalti.IFrame.SetupProcess` - Setup Process iFrame integration helper
  """

  @typedoc """
  An `idap` is a string representing the id of a payee in Tipalti.
  """
  @type idap :: String.t()

  @typedoc """
  Key/Value pair used for custom fields.
  """
  @type key_value_pair :: %{key: String.t(), value: String.t()}
end
