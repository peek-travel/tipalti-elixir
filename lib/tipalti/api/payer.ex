defmodule Tipalti.API.Payer do
  alias Tipalti.API.SOAP.Client
  import SweetXml, only: [sigil_x: 2]

  @version "v7"
  @url %{
    sandbox: "https://api.sandbox.tipalti.com/#{@version}/PayerFunctions.asmx",
    production: "https://api.tipalti.com/#{@version}/PayerFunctions.asmx"
  }

  # TODO: ApplyVendorCredit

  # TODO: CreateExtendedPayeeStatusFile

  # TODO: CreateOrUpdateCustomFields

  # TODO: CreateOrUpdateGLAccounts

  # TODO: CreateOrUpdateGrns

  # TODO: CreateOrUpdateInvoices

  # TODO: CreateOrUpdatePurchaseOrders

  # TODO: CreatePayeeStatusFile

  # TODO: CreatePaymentOrdersReport

  # TODO: GetBalances

  # TODO: GetCustomFields

  # TODO: GetDynamicKey

  # TODO: GetDynamicKeyOfSubPayer

  # TODO: GetPayeeInvoicesListDetails

  # TODO: GetPayerFees

  # TODO: GetProcessingRequestStatus

  # TODO: GetProviderAccounts

  # TODO: GetUpdatedPayments

  # TODO: LogIntegrationError

  # TODO: ProcessMultiCurrencyPaymentFile

  # TODO: ProcessMultiCurrencyPaymentFileAsync

  # TODO: ProcessPaymentFile

  # TODO: ProcessPaymentFileAsync

  # TODO: ProcessPayments

  # TODO: ProcessPaymentsAsync

  # TODO: ProcessPaymentsAsyncResult

  # TODO: TestMultiCurrencyPaymentFile

  # TODO: TestMultiCurrencyPaymentFileAsync

  # TODO: TestPaymentFile

  # TODO: TestPaymentFileAsync

  # TODO: TestPayments

  # TODO: TestPaymentsAsync

  defp run(function_name, request, key_parts, response_paths),
    do: Client.run(@url, function_name, request, key_parts, response_paths)

  defp get_required_opt(opts, key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} ->
        {:ok, value}

      :error ->
        {:error, {:missing_required_option, key}}
    end
  end
end
