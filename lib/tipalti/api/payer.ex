defmodule Tipalti.API.Payer do
  alias Tipalti.API.SOAP.Client
  import SweetXml, only: [sigil_x: 2]

  @version "v7"

  use Tipalti.API,
    url: [
      sandbox: "https://api.sandbox.tipalti.com/#{@version}/PayerFunctions.asmx",
      production: "https://api.tipalti.com/#{@version}/PayerFunctions.asmx"
    ],
    standard_response: [
      ok_code: 0,
      error_paths: [error_code: ~x"./errorCode/text()"i, error_message: ~x"./errorMessage/text()"os]
    ]

  # TODO: ApplyVendorCredit

  # TODO: CreateExtendedPayeeStatusFile

  # TODO: CreateOrUpdateCustomFields

  # TODO: CreateOrUpdateGLAccounts

  # TODO: CreateOrUpdateGrns

  # TODO: CreateOrUpdateInvoices

  # TODO: CreateOrUpdatePurchaseOrders

  # TODO: CreatePayeeStatusFile

  # TODO: CreatePaymentOrdersReport

  def get_balances() do
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
