defmodule Tipalti.API.Payer do
  @moduledoc """
  Payer functions.

  Details are taken from: https://api.tipalti.com/v5/PayerFunctions.asmx
  """

  alias Tipalti.API.SOAP.Client
  import SweetXml, only: [sigil_x: 2]

  @version "v5"

  use Tipalti.API,
    url: [
      sandbox: "https://api.sandbox.tipalti.com/#{@version}/PayerFunctions.asmx",
      production: "https://api.tipalti.com/#{@version}/PayerFunctions.asmx"
    ],
    standard_response: [
      ok_code: 0,
      error_paths: [error_code: ~x"./errorCode/text()"i, error_message: ~x"./errorMessage/text()"os]
    ]

  @typedoc """
  All Payer API responses are of this form.

  Errors are not really standardized yet.
  """
  @type payer_response :: {:ok, map()} | {:error, any()}

  # TODO: ApplyVendorCredit

  # TODO: CreateExtendedPayeeStatusFile

  # TODO: CreateOrUpdateCustomFields

  # TODO: CreateOrUpdateGLAccounts

  # TODO: CreateOrUpdateGrns

  # TODO: CreateOrUpdateInvoices

  # TODO: CreateOrUpdatePurchaseOrders

  # TODO: CreatePayeeStatusFile

  # TODO: CreatePaymentOrdersReport

  @doc """
  Get balances in your accounts.

  Returns account provider, account identifier, currency and amount in balance.
  Note: when submitting a payment, the balance may take some time before it is updated.

  ## Examples

        iex> get_balances
        {:ok,
          %{
            account_infos: [
              %{
                account_identifier: "1234",
                balance: "1000",
                currency: "USD",
                provider: "Tipalti"
              }
            ]
          }}
  """
  @spec get_balances() :: payer_response()
  def get_balances do
    run("GetBalances", [], [:payer_name, :timestamp], {
      ~x"//GetBalancesResult",
      account_infos: [
        ~x"./AccountInfos/TipaltiAccountInfo"l,
        provider: ~x"./Provider/text()"os,
        account_identifier: ~x"./AccountIdentifier/text()"os,
        balance: ~x"./Balance/text()"os,
        currency: ~x"./Currency/text()"os
      ]
    })
  end

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
end
