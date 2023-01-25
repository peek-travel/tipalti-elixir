defmodule Tipalti.API.Payer do
  @moduledoc """
  Payer functions.

  Details are taken from: <https://api.tipalti.com/v5/PayerFunctions.asmx>
  """

  import SweetXmlFork, only: [sigil_x: 2]

  alias Tipalti.{API.SOAP.Client, Balance, ClientError, Invoice, RequestError}

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

  @doc """
  Not yet implemented
  """
  @spec apply_vendor_credit :: {:error, :not_yet_implemented}
  def apply_vendor_credit, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec create_extended_payee_status_file :: {:error, :not_yet_implemented}
  def create_extended_payee_status_file, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec create_or_update_custom_fields :: {:error, :not_yet_implemented}
  def create_or_update_custom_fields, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec create_or_update_gl_accounts :: {:error, :not_yet_implemented}
  def create_or_update_gl_accounts, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec create_or_update_grns :: {:error, :not_yet_implemented}
  def create_or_update_grns, do: {:error, :not_yet_implemented}

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
          required(:date) => String.t(),
          required(:idap) => Tipalti.idap(),
          required(:subject) => String.t(),
          required(:can_approve) => boolean(),
          required(:is_paid_manually) => boolean(),
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

  See <https://support.tipalti.com/Content/Topics/Development/APIs/PayeeAPI/Intro.htm> for details.

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

  `{:ok, list}` where list is a list of maps contains the following fields:

  * `error_message`: String; if there was an error creating the invoice.
  * `ref_code`: String; corresponds to the input invoices.
  * `succeeded`: Boolean; Indicates if creating the invoice succeeded.

  ## Examples

      iex> create_or_update_invoices([%{idap: "somepayee", can_approve: false, is_paid_manually: false, ref_code: "testinvoice1", due_date: "2018-05-01", date: "2018-06-01", subject: "test invoice 1", currency: "USD", line_items: [%{amount: "100.00", description: "test line item"}]}, %{idap: "somepayee", ref_code: "testinvoice2", due_date: "2018-06-01", date: "2018-05-01", subject: "test invoice 2", currency: "USD", line_items: [%{amount: "100.00", description: "test line item"}]}])
      {:ok,
      [
        %{
          error_message: "Due date cannot be earlier then invoice date",
          ref_code: "testinvoice1",
          succeeded: false
        },
        %{error_message: nil, ref_code: "testinvoice2", succeeded: true}
      ]}

      iex> too_long_description = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      iex> create_or_update_invoices([%{idap: "somepayee", ref_code: "testinvoice3", due_date: "2018-05-01", date: "2018-06-01", description: too_long_description, currency: "USD", line_items: [%{amount: "100.00", description: "test line item"}]}])
      {:error, %Tipalti.ClientError{error_code: "UnknownError", error_message: "Internal server errror"}}

      iex> custom_fields = [%{key: "foo", value: "bar"}]
      ...> line_items = [%{amount: "100.00", description: "test line item", custom_fields: custom_fields}]
      ...> approvers = [%{name: "Mr. Approver", email: "approver@example.com", order: 1}]
      ...> invoice = %{idap: "somepayee", can_approve: false, is_paid_manually: false, ref_code: "testinvoice", due_date: "2018-06-01", date: "2018-05-01", subject: "test invoice", currency: "USD", line_items: line_items, custom_fields: custom_fields, approvers: approvers}
      ...> create_or_update_invoices([invoice])
      {:ok, [%{error_message: nil, ref_code: "testinvoice", succeeded: true}]}
  """
  @spec create_or_update_invoices([invoice()]) ::
          {:ok, [%{error_message: String.t() | nil, ref_code: String.t(), succeeded: boolean()}]}
          | {:error, RequestError.t()}
  def create_or_update_invoices(invoices_params) do
    payload =
      RequestBuilder.build(
        "CreateOrUpdateInvoices",
        [
          invoices:
            optional_list(invoices_params, fn invoice ->
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
      invoice_responses =
        ResponseParser.parse_without_errors(
          body,
          ~x"//CreateOrUpdateInvoicesResult",
          [
            ~x"./InvoiceErrors/TipaltiInvoiceItemResult"l,
            error_message: ~x"./ErrorMessage/text()"os,
            succeeded: ~x"./Succeeded/text()"b,
            ref_code: ~x"./InvoiceRefCode/text()"os
          ]
        )

      if invoice_responses == [] && invoices_params != [] do
        {:error,
         ResponseParser.parse_errors(body, ~x"//CreateOrUpdateInvoicesResult",
           error_code: ~x"./errorCode/text()"s,
           error_message: ~x"./errorMessage/text()"os
         )}
      else
        {:ok, invoice_responses}
      end
    end
  end

  defp optional_list(nil, _), do: nil
  defp optional_list([], _), do: nil
  defp optional_list(items, fun), do: Enum.map(items, fun)

  @doc """
  Not yet implemented
  """
  @spec create_or_update_purchase_orders :: {:error, :not_yet_implemented}
  def create_or_update_purchase_orders, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec create_payee_status_file :: {:error, :not_yet_implemented}
  def create_payee_status_file, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec create_payment_orders_report :: {:error, :not_yet_implemented}
  def create_payment_orders_report, do: {:error, :not_yet_implemented}

  @doc """
  Get balances in your accounts.

  Returns account provider, account identifier, currency and amount in balance.
  Note: when submitting a payment, the balance may take some time before it is updated.

  ## Examples

      iex> get_balances()
      {:ok,
      [
        %Tipalti.Balance{
          account_identifier: "1234",
          balance: Money.new("USD", "1000"),
          provider: "Tipalti"
        }
      ]}
  """
  @spec get_balances :: {:ok, [Tipalti.Balance.t()]} | {:error, ClientError.t()} | {:error, RequestError.t()}
  def get_balances do
    with {:ok, balances_maps} <-
           run(
             "GetBalances",
             [],
             [:payer_name, :timestamp],
             {
               ~x"//GetBalancesResult",
               [
                 ~x"./AccountInfos/TipaltiAccountInfo"l,
                 provider: ~x"./Provider/text()"os,
                 account_identifier: ~x"./AccountIdentifier/text()"os,
                 balance: ~x"./Balance/text()"os,
                 currency: ~x"./Currency/text()"os
               ]
             },
             ok_code: 0,
             error_paths: [error_code: ~x"./errorCode/text()"i, error_message: ~x"./errorMessage/text()"os]
           ) do
      {:ok, Balance.from_maps!(balances_maps)}
    end
  end

  @doc """
  Not yet implemented
  """
  @spec get_custom_fields :: {:error, :not_yet_implemented}
  def get_custom_fields, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_dynamic_key :: {:error, :not_yet_implemented}
  def get_dynamic_key, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_dynamic_key_of_sub_payer :: {:error, :not_yet_implemented}
  def get_dynamic_key_of_sub_payer, do: {:error, :not_yet_implemented}

  @doc """
  Return list of payee invoices.

  ## Parameters

    * `invoice_ref_codes`: list of invoice reference codes

  ## Examples

      iex> get_payee_invoices_list_details(["12345","12346"])
      {:ok,
      [
        %Tipalti.Invoice{
          amount_due: Money.new!(:USD, "3.61"),
          approval_date: nil,
          approvers: [],
          can_approve: false,
          custom_fields: [],
          date: ~D[2018-07-23],
          description: "Some invoice",
          due_date: ~D[2018-07-27],
          idap: "payee1",
          internal_notes: "Notes",
          is_paid_manually: false,
          line_items: [
            %Tipalti.Invoice.Line{
              amount: Money.new!(:USD, "3.61"),
              custom_fields: [],
              description: "Charges",
              line_type: nil,
              quantity: nil
            }
          ],
          number: "h6gz1gs2e",
          payer_entity_name: "SomePayee",
          ref_code: "12345",
          status: :pending_payment
        },
        %Tipalti.Invoice{
          amount_due: Money.new!(:USD, "10.47"),
          approval_date: nil,
          approvers: [],
          can_approve: false,
          custom_fields: [],
          date: ~D[2018-07-18],
          description: "Some other invoice",
          due_date: ~D[2018-07-20],
          idap: "payee2",
          internal_notes: "Notes notes notes",
          is_paid_manually: false,
          line_items: [
            %Tipalti.Invoice.Line{
              amount: Money.new!(:USD, "10.47"),
              custom_fields: [],
              description: "Charges",
              line_type: nil,
              quantity: nil
            }
          ],
          number: "h6gz1grv4",
          payer_entity_name: "SomePayee",
          ref_code: "12346",
          status: :pending_payment
        }
      ]}
  """
  @spec get_payee_invoices_list_details([Invoice.ref_code()]) ::
          {:ok, [Invoice.t()]} | {:error, ClientError.t()} | {:error, RequestError.t()}
  def get_payee_invoices_list_details(invoice_ref_codes) do
    with {:ok, %{errors: _errors, invoices: invoice_maps}} <-
           run(
             "GetPayeeInvoicesListDetails",
             [invoicesRefCodes: Enum.map(invoice_ref_codes, fn ref_code -> [string: ref_code] end)],
             [:payer_name, :timestamp],
             {
               ~x"//GetPayeeInvoicesListDetailsResult",
               errors: [
                 ~x"./InvoiceErrors/TipaltiInvoiceItemError"l,
                 error_message: ~x"./ErrorMessage/text()"s,
                 error_code: ~x"./ErrorCode/text()"s,
                 ref_code: ~x"./InvoiceRefCode/text()"s
               ],
               invoices: [
                 ~x"./Invoices/TipaltiInvoiceItemResponse"l,
                 idap: ~x"./Idap/text()"s,
                 ref_code: ~x"./InvoiceRefCode/text()"s,
                 date: ~x"./InvoiceDate/text()"s,
                 due_date: ~x"./InvoiceDueDate/text()"s,
                 line_items: [
                   ~x"./InvoiceLines/InvoiceLine"l,
                   currency: ~x"./Currency/text()"s,
                   amount: ~x"./Amount/text()"s,
                   description: ~x"./Description/text()"s,
                   custom_fields: [
                     ~x"./CustomFields/KeyValuePair"l,
                     key: ~x"./Key/text()"os,
                     value: ~x"./Value/text()"os
                   ],
                   line_type: ~x"./LineType/text()"os,
                   quantity: ~x"./Quantity/text()"oi
                 ],
                 description: ~x"./Description/text()"s,
                 can_approve: ~x"./CanApprove/text()"b,
                 internal_notes: ~x"./InvoiceInternalNotes/text()"s,
                 custom_fields: [
                   ~x"./CustomFields/KeyValuePair"l,
                   key: ~x"./Key/text()"os,
                   value: ~x"./Value/text()"os
                 ],
                 is_paid_manually: ~x"./IsPaidManually/text()"b,
                 status: ~x"./InvoiceStatus/text()"s,
                 currency: ~x"./Currency/text()"s,
                 approvers: [
                   ~x"./Approvers/TipaltiInvoiceApprover"l,
                   name: ~x"./Name/text()"s,
                   email: ~x"./Email/text()"s,
                   order: ~x"./Order/text()"oi
                 ],
                 number: ~x"./InvoiceNumber/text()"s,
                 approval_date: ~x"./ApprovalDate/text()"s,
                 payer_entity_name: ~x"./PayerEntityName/text()"s,
                 amount_due: ~x"./AmountDue/text()"s
               ]
             }
           ) do
      {:ok, Invoice.from_maps!(invoice_maps)}
    end
  end

  @doc """
  Not yet implemented
  """
  @spec get_payer_fees :: {:error, :not_yet_implemented}
  def get_payer_fees, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_processing_request_status :: {:error, :not_yet_implemented}
  def get_processing_request_status, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_provider_accounts :: {:error, :not_yet_implemented}
  def get_provider_accounts, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_updated_payments :: {:error, :not_yet_implemented}
  def get_updated_payments, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec log_integration_error :: {:error, :not_yet_implemented}
  def log_integration_error, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec process_multi_currency_payment_file :: {:error, :not_yet_implemented}
  def process_multi_currency_payment_file, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec process_multi_currency_payment_file_async :: {:error, :not_yet_implemented}
  def process_multi_currency_payment_file_async, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec process_payment_file :: {:error, :not_yet_implemented}
  def process_payment_file, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec process_payment_file_async :: {:error, :not_yet_implemented}
  def process_payment_file_async, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec process_payments :: {:error, :not_yet_implemented}
  def process_payments, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec process_payments_async :: {:error, :not_yet_implemented}
  def process_payments_async, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec process_payments_async_result :: {:error, :not_yet_implemented}
  def process_payments_async_result, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec test_multi_currency_payment_file :: {:error, :not_yet_implemented}
  def test_multi_currency_payment_file, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec test_multi_currency_payment_file_async :: {:error, :not_yet_implemented}
  def test_multi_currency_payment_file_async, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec test_payment_file :: {:error, :not_yet_implemented}
  def test_payment_file, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec test_payment_file_async :: {:error, :not_yet_implemented}
  def test_payment_file_async, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec test_payments :: {:error, :not_yet_implemented}
  def test_payments, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec test_payments_async :: {:error, :not_yet_implemented}
  def test_payments_async, do: {:error, :not_yet_implemented}
end
