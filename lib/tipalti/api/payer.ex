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

  @typedoc """
  An invoice approver, used when creating invoices in `create_or_update_invoices/1`.
  """
  @type invoice_approver :: %{
          required(:email) => String.t(),
          required(:name) => String.t(),
          optional(:order) => integer()
        }

  @typedoc """
  An invoice line item, used when creating invoices in `create_or_update_invoices/1`.
  """
  @type invoice_line_item :: %{
          required(:amount) => String.t(),
          optional(:banking_message) => String.t(),
          optional(:currency) => String.t(),
          optional(:custom_fields) => [Tipalti.key_value_pair()],
          optional(:description) => String.t(),
          optional(:e_wallet_message) => String.t(),
          optional(:external_metadata) => String.t(),
          optional(:internal_notes) => String.t(),
          optional(:line_type) => String.t(),
          optional(:quantity) => integer()
        }

  @typedoc """
  An invoice, used when creating invoices in `create_or_update_invoices/1`.
  """
  @type invoice :: %{
          required(:can_approve) => boolean(),
          required(:date) => String.t(),
          required(:idap) => Tipalti.idap(),
          required(:is_paid_manually) => boolean(),
          required(:subject) => String.t(),
          optional(:ap_account_number) => String.t(),
          optional(:approvers) => [invoice_approver()],
          optional(:currency) => String.t(),
          optional(:custom_fields) => [Tipalti.key_value_pair()],
          optional(:description) => String.t(),
          optional(:due_date) => String.t(),
          optional(:income_type) => String.t(),
          optional(:internal_notes) => String.t(),
          optional(:line_items) => [invoice_line_item()],
          optional(:number) => String.t(),
          optional(:payer_entity_name) => String.t(),
          optional(:ref_code) => String.t(),
          optional(:status) => String.t()
        }

  @doc """
  Create new invoices or update existing ones.

  Returns a list of invoice responses for each invoice,
  indicating if it succeeded and what the errors were if it didn't.

  See <https://support.tipalti.com/Content/Topics/Development/APIs/PayerApi.htm> for details.

  ## Parameters

  * `invoices[]`: List of maps of invoice params.
    * `idap`: Payee id.
    * `ref_code`: Uniq id for this invoice (leave null for auto-generated id).
    * `date`: Invoice value date (estimated date and time the payee receives the funds).
    * `due_date`: The date and time the invoice is due to be paid.
    * `line_items[]`: List of invoice lines.
      * `currency`: Invoice currency.
      * `amount`: Invoice line amount.
      * `description`: Description of the invoice line.
      * `internal_notes`: Notes which are not displayed to the payee.
      * `e_wallet_message`: A message to attach to the payment. This message is sent to providers and appears on payee bank statements. If no value is provided, the InvoiceRefCode is used..
      * `banking_message`: A message to attach to the payment. This message is sent to providers and appears on payee bank statements. If a value is not provided, the EWalletMessage is used.
      * `custom_fields[]`: If custom fields have been defined for the invoice entity, the values of these fields can be set here. The field name must match the defined custom field name.
        * `key`: The custom field key.
        * `value`: The custom field value.
      * `line_type`: ?
      * `external_metadata`: ?
      * `quantity`: ?
    * `description`: Description of the invoice.
    * `can_approve`: Indicates whether or not the payee is able to approve the invoice.
    * `internal_notes`: Notes, which are not displayed to the payee.
    * `custom_fields[]`: If custom fields have been defined for the invoice entity, the values of these fields can be set here. The field name must match the defined custom field name.
      * `key`: The custom field key.
      * `value`: The custom field value.
    * `is_paid_manually`: If `true`, the invoice is marked as paid manually.
    * `income_type`: If the Tax Withholding module is enabled and there are multiple income types that can be associated with the payment, then you must enter the IncomeType per payment.
    * `status`:  ?
    * `currency`: Invoice currency.
    * `approvers`: ?
    * `number`: ?
    * `payer_entity_name`: The name of the payer entity linked to the invoice.
    * `subject`: The text for the title of the invoice, displays for the payee in the Payee Dashboard or Suppliers Portal.
    * `ap_account_number`: ?

  ## Returns

  `{:ok, map}` where map contains the following fields:

  * `invoice_results`: List of invoice results
    * `error_message`: String; if there was an error creating the invoice.
    * `ref_code`: String; corresponds to the input invoices.
    * `succeeded`: Boolean; Indicates if creating the invoice succeeded.

  ## Examples

      iex> create_or_update_invoices([%{idap: "somepayee", ref_code: "testinvoice1", due_date: "2018-05-01", date: "2018-06-01", subject: "test invoice 1", currency: "USD", line_items: [%{amount: "100.00", description: "test line item"}]}, %{idap: "somepayee", ref_code: "testinvoice2", due_date: "2018-06-01", date: "2018-05-01", subject: "test invoice 2", currency: "USD", line_items: [%{amount: "100.00", description: "test line item"}]}])
      {:ok,
       %{
         invoice_results: [
           %{
             error_message: "Due date cannot be earlier then invoice date",
             ref_code: "testinvoice1",
             succeeded: false
           },
           %{error_message: nil, ref_code: "testinvoice2", succeeded: true}
         ]
       }}
  """
  @spec create_or_update_invoices([invoice()]) :: payer_response()
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
      response =
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

      {:ok, response}
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
