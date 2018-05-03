defmodule Tipalti.API.Payer do
  @moduledoc """
  Payer functions.

  Details are taken from: <https://api.tipalti.com/v5/PayerFunctions.asmx>
  """

  alias Tipalti.API.SOAP.Client
  import SweetXml, only: [sigil_x: 2]

  @version "v5"
  @url [
    sandbox: "https://api.sandbox.tipalti.com/#{@version}/PayerFunctions.asmx",
    production: "https://api.tipalti.com/#{@version}/PayerFunctions.asmx"
  ]

  use Tipalti.API,
    url: @url,
    standard_response: [
      ok_code: "OK",
      error_paths: [error_code: ~x"./errorCode/text()"s, error_message: ~x"./errorMessage/text()"os]
    ]

  @typedoc """
  All Payer API responses are of this form.
  """
  @type payer_response :: {:ok, map()} | {:error, any()}

  # TODO: ApplyVendorCredit

  # TODO: CreateExtendedPayeeStatusFile

  # TODO: CreateOrUpdateCustomFields

  # TODO: CreateOrUpdateGLAccounts

  # TODO: CreateOrUpdateGrns

  @doc """
  TODO
  """
  def create_or_update_invoices(invoices) do
    payload =
      RequestBuilder.build(
        "CreateOrUpdateInvoices",
        [
          invoices:
            optional_list(invoices, fn invoice ->
              {:TipaltiInvoiceItemRequest,
               [
                 Idap: invoice[:idap],
                 InvoiceRefCode: invoice[:ref_code],
                 InvoiceDate: invoice[:date],
                 InvoiceDueDate: invoice[:due_date],
                 InvoiceLines:
                   optional_list(invoice[:line_items], fn line_item ->
                     {:InvoiceLine,
                      [
                        Currency: line_item[:currency],
                        Amount: line_item[:amount],
                        Description: line_item[:description],
                        InvoiceInternalNotes: line_item[:internal_notes],
                        EWalletMessage: line_item[:e_wallet_message],
                        BankingMessage: line_item[:banking_message],
                        CustomFields:
                          optional_list(line_item[:custom_fields], fn custom_field ->
                            {:KeyValuePair, Key: custom_field[:key], Value: custom_field[:value]}
                          end),
                        # TODO: figure out what this is and how to support it
                        GLAccount: nil,
                        LineType: line_item[:line_type],
                        LineExternalMetadata: line_item[:external_metadata],
                        Quantity: line_item[:quantity]
                      ]}
                   end),
                 Description: invoice[:description],
                 CanApprove: invoice[:can_approve],
                 InvoiceInternalNotes: invoice[:internal_notes],
                 CustomFields:
                   optional_list(invoice[:custom_fields], fn custom_field ->
                     {:KeyValuePair, Key: custom_field[:key], Value: custom_field[:value]}
                   end),
                 IsPaidManually: invoice[:is_paid_manually],
                 IncomeType: invoice[:income_type],
                 InvoiceStatus: invoice[:status],
                 Currency: invoice[:currency],
                 Approvers:
                   optional_list(invoice[:approvers], fn approver ->
                     {:TipaltiInvoiceApprover, Name: approver[:name], Email: approver[:email], Order: approver[:order]}
                   end),
                 InvoiceNumber: invoice[:number],
                 PayerEntityName: invoice[:payer_entity_name],
                 InvoiceSubject: invoice[:subject],
                 ApAccountNumber: invoice[:ap_account_number]
               ]}
            end)
        ],
        [:payer_name, :timestamp]
      )

    client = Application.get_env(:tipalti, :api_client_module, Client)

    with {:ok, body} <- client.send(@url, payload) do
      ResponseParser.parse_without_errors(
        body,
        ~x"//CreateOrUpdateInvoicesResult",
        invoice_results: [
          ~x"./InvoiceErrors/TipaltiInvoiceItemResult"l,
          error_message: ~x"./ErrorMessage/text()"os,
          succeeded: ~x"./Succeeded/text()"b,
          ref_code: ~x"./InvoiceRefCode/text()"os
        ]
      )
    end
  end

  defp optional_list(nil, _), do: nil
  defp optional_list([], _), do: nil
  defp optional_list(items, fun), do: Enum.map(items, fun)

  # TODO: CreateOrUpdatePurchaseOrders

  # TODO: CreatePayeeStatusFile

  # TODO: CreatePaymentOrdersReport

  @doc """
  Get balances in your accounts.

  Returns account provider, account identifier, currency and amount in balance.
  Note: when submitting a payment, the balance may take some time before it is updated.

  ## Examples

        iex> get_balances()
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
    run(
      "GetBalances",
      [],
      [:payer_name, :timestamp],
      {
        ~x"//GetBalancesResult",
        account_infos: [
          ~x"./AccountInfos/TipaltiAccountInfo"l,
          provider: ~x"./Provider/text()"os,
          account_identifier: ~x"./AccountIdentifier/text()"os,
          balance: ~x"./Balance/text()"os,
          currency: ~x"./Currency/text()"os
        ]
      },
      ok_code: 0,
      error_paths: [error_code: ~x"./errorCode/text()"i, error_message: ~x"./errorMessage/text()"os]
    )
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
