defmodule Tipalti.API.Payee do
  @moduledoc """
  Obtain or update payee info.

  Details are taken from: <https://api.tipalti.com/v6/PayeeFunctions.asmx>
  """

  import SweetXmlFork, only: [sigil_x: 2]

  alias Tipalti.{ClientError, Payee, PayeeExtended, RequestError}

  @version "v6"
  @url [
    sandbox: "https://api.sandbox.tipalti.com/#{@version}/PayeeFunctions.asmx",
    production: "https://api.tipalti.com/#{@version}/PayeeFunctions.asmx"
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
  @spec cancel_invoice :: {:error, :not_yet_implemented}
  def cancel_invoice, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec close_payee_account :: {:error, :not_yet_implemented}
  def close_payee_account, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec create_payee_info_auto_idap :: {:error, :not_yet_implemented}
  def create_payee_info_auto_idap, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_extended_payee_details :: {:error, :not_yet_implemented}
  def get_extended_payee_details, do: {:error, :not_yet_implemented}

  @doc """
  Returns extended details and custom fields of given payees.

  ## Parameters

    * `idaps`: list of payee ids

  ## Examples

        iex> get_extended_payee_details_list(["somepayee"])
        {:ok,
        [
          %Tipalti.PayeeExtended{
            custom_fields: [],
            properties: %Tipalti.PayeeExtended.Properties{
              actual_payer_entity: "Peek",
              alias: "acmepayee",
              city: nil,
              company_name: "ACME",
              country: "--",
              email: "someone@example.com",
              first_name: "Some",
              idap: "somepayee",
              last_name: "Payee",
              middle_name: nil,
              payable: false,
              payment_currency: "USD",
              payment_method: "NoPM",
              phone: nil,
              portal_user: "NotRegistered",
              preferred_payer_entity: "Peek",
              state: nil,
              status: "Active",
              street1: "123 Somewhere St.",
              street2: nil,
              tax_form_entity_name: nil,
              tax_form_entity_type: "UNKNOWN",
              tax_form_status: "NOT_SUBMITTED",
              tax_form_type: nil,
              withholding_rate: nil,
              zip: nil
            }
          }
        ]}

        iex> get_extended_payee_details_list(["badpayee"])
        {:ok, []}
  """
  @spec get_extended_payee_details_list([Tipalti.idap()]) ::
          {:ok, [PayeeExtended.t()]} | {:error, ClientError.t()} | {:error, RequestError.t()}
  def get_extended_payee_details_list(idaps) do
    prop_getter = fn key -> "./KeyValuePair/Key[text()='#{key}']/../Value/text()" end
    lower_cased = fn str -> "translate(#{str}, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" end

    with {:ok, payee_maps} <-
           run(
             "GetExtendedPayeeDetailsList",
             [idaps: Enum.map(idaps, fn idap -> [string: idap] end)],
             [:payer_name, :timestamp],
             {~x"//GetExtendedPayeeDetailsListResult",
              [
                ~x"./Payees/TipaltiExtendedPayeeDetailsResponse"l,
                properties: [
                  ~x"./Properties",
                  idap: ~x"#{prop_getter.("Idap")}"os,
                  alias: ~x"#{prop_getter.("Alias")}"os,
                  company_name: ~x"#{prop_getter.("CompanyName")}"os,
                  email: ~x"#{prop_getter.("Email")}"os,
                  first_name: ~x"#{prop_getter.("FirstName")}"os,
                  middle_name: ~x"#{prop_getter.("MiddleName")}"os,
                  last_name: ~x"#{prop_getter.("LastName")}"os,
                  payment_method: ~x"#{prop_getter.("PaymentMethod")}"os,
                  street1: ~x"#{prop_getter.("Street1")}"os,
                  street2: ~x"#{prop_getter.("Street2")}"os,
                  city: ~x"#{prop_getter.("City")}"os,
                  state: ~x"#{prop_getter.("State")}"os,
                  zip: ~x"#{prop_getter.("Zip")}"os,
                  country: ~x"#{prop_getter.("Country")}"os,
                  phone: ~x"#{prop_getter.("Phone")}"os,
                  payment_currency: ~x"#{prop_getter.("PaymentCurrency")}"os,
                  payable: ~x"#{lower_cased.(prop_getter.("Payable"))}"b,
                  status: ~x"#{prop_getter.("Status")}"os,
                  preferred_payer_entity: ~x"#{prop_getter.("PreferredPayerEntity")}"os,
                  actual_payer_entity: ~x"#{prop_getter.("ActualPayerEntity")}"os,
                  tax_form_status: ~x"#{prop_getter.("TaxFormStatus")}"os,
                  portal_user: ~x"#{prop_getter.("PortalUser")}"os,
                  withholding_rate: ~x"#{prop_getter.("WithholdingRate")}"os,
                  tax_form_entity_type: ~x"#{prop_getter.("TaxFormEntityType")}"os,
                  tax_form_entity_name: ~x"#{prop_getter.("TaxFormEntityName")}"os,
                  tax_form_type: ~x"#{prop_getter.("TaxFormType")}"os
                ],
                custom_fields: [
                  ~x"./CustomFields/KeyValuePair"l,
                  key: ~x"./Key/text()"os,
                  value: ~x"./Value/text()"os
                ]
              ]}
           ) do
      {:ok, PayeeExtended.from_maps!(payee_maps)}
    end
  end

  @doc """
  Not yet implemented
  """
  @spec get_extended_po_details :: {:error, :not_yet_implemented}
  def get_extended_po_details, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_extended_po_details_list :: {:error, :not_yet_implemented}
  def get_extended_po_details_list, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_invoices_payable_amount :: {:error, :not_yet_implemented}
  def get_invoices_payable_amount, do: {:error, :not_yet_implemented}

  @doc """
  Returns details of a given payee.

  ## Parameters

    * `idap`: a payee id

  ## Examples

        iex> get_payee_details("somepayee")
        {:ok,
          %Tipalti.Payee{
            address: "123 Somewhere St.",
            alias: "acmepayee",
            company_name: "ACME",
            email: "someone@example.com",
            name: "Some Payee",
            payment_method: "Check",
            payment_terms_id: nil,
            payment_terms_name: nil
          }}

        iex> get_payee_details("badpayee")
        {:error, %Tipalti.ClientError{error_code: "PayeeUnknown", error_message: "PayeeUnknown"}}
  """
  @spec get_payee_details(Tipalti.idap()) :: {:ok, Payee.t()} | {:error, ClientError.t()} | {:error, RequestError.t()}
  def get_payee_details(idap) do
    with {:ok, payee_map} <-
           run("GetPayeeDetails", [idap: idap], [:payer_name, idap, :timestamp], {
             ~x"//GetPayeeDetailsResult",
             name: ~x"./Name/text()"os,
             company_name: ~x"./CompanyName/text()"os,
             alias: ~x"./Alias/text()"os,
             address: ~x"./Address/text()"os,
             payment_method: ~x"./PaymentMethod/text()"os,
             email: ~x"./Email/text()"os,
             payment_terms_id: ~x"./PaymentTermsID/text()"os,
             payment_terms_name: ~x"./PaymentTermsName/text()"os
           }) do
      {:ok, Payee.from_map!(payee_map)}
    end
  end

  @doc """
  Not yet implemented
  """
  @spec get_payee_invoice_list :: {:error, :not_yet_implemented}
  def get_payee_invoice_list, do: {:error, :not_yet_implemented}

  @doc """
  Returns all invoice reference codes that were updated since the given UTC timestamp.

  ## Parameters

    * `utc_time`: a UTC DateTime struct

  ## Examples

        iex> {:ok, utc_time, _} = DateTime.from_iso8601("2018-07-01T00:00:00Z")
        iex> get_payee_invoices_changed_since_timestamp(utc_time)
        {:ok, ["12345", "12346", "12347"]}
  """
  @spec get_payee_invoices_changed_since_timestamp(DateTime.t()) ::
          {:ok, [String.t()]} | {:error, ClientError.t()} | {:error, RequestError.t()}
  def get_payee_invoices_changed_since_timestamp(utc_time) do
    timestamp = utc_time |> DateTime.to_unix() |> to_string()

    run("GetPayeeInvoicesChangedSinceTimestamp", [changedSince: timestamp], [:payer_name, :timestamp, timestamp], {
      ~x"//GetPayeeInvoicesChangedSinceTimestampResult",
      ~x"./changedInvoicesRefCode/string/text()"ls
    })
  end

  @doc """
  Not yet implemented
  """
  @spec get_payee_pending_invoice_total :: {:error, :not_yet_implemented}
  def get_payee_pending_invoice_total, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_payees_changed_since_timestamp :: {:error, :not_yet_implemented}
  def get_payees_changed_since_timestamp, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec get_po_details :: {:error, :not_yet_implemented}
  def get_po_details, do: {:error, :not_yet_implemented}

  @doc """
  Return payable status of payee.

  If a payment request were to be issued, the payee might not get paid.
  Possible reasons for not being paid are - missing tax documents, payment below threshold, account locked, address
  missing, or other.

  ## Parameters

  * `idap`: a payee id
  * `amount`: the amount for which you'd want to pay this payee (default: `100.0`)

  ## Examples

        iex> payee_payable("payablepayee", 100)
        {:ok, true}

        iex> payee_payable("unpayablepayee")
        {:ok, false, "Tax,No PM"}

        iex> payee_payable("badpayee", 123.45)
        {:error, %Tipalti.ClientError{error_code: "PayeeUnknown", error_message: "PayeeUnknown"}}
  """
  @spec payee_payable(Tipalti.idap(), integer() | float()) ::
          {:ok, true} | {:ok, false, String.t()} | {:error, ClientError.t()} | {:error, RequestError.t()}
  def payee_payable(idap, amount \\ 100.0) do
    with {:ok, %{payable: payable, reason: reason}} <-
           run(
             "PayeePayable",
             [idap: idap, amount: amount],
             [:payer_name, idap, :timestamp, {:float, amount}],
             {~x"//PayeePayableResult", reason: ~x"./s/text()"os, payable: ~x"./b/text()"b}
           ) do
      if payable do
        {:ok, true}
      else
        {:ok, false, reason}
      end
    end
  end

  @doc """
  Returns the name of the payee's selected payment method.

  ## Examples

        iex> payee_payment_method("payablepayee")
        {:ok, "Check"}

        iex> payee_payment_method("unpayablepayee")
        {:ok, "No payment method"}

        iex> payee_payment_method("badpayee")
        {:error, %Tipalti.ClientError{error_code: "PayeeUnknown", error_message: "PayeeUnknown"}}
  """
  @spec payee_payment_method(Tipalti.idap()) ::
          {:ok, String.t()} | {:error, ClientError.t()} | {:error, RequestError.t()}
  def payee_payment_method(idap) do
    run(
      "PayeePaymentMethod",
      [idap: idap],
      [:payer_name, idap, :timestamp],
      {~x"//PayeePaymentMethodResult", ~x"./s/text()"s}
    )
  end

  @doc """
  Update the status of payee.

  Valid values for status are: `:active`, `:suspended`, or `:blocked`.
  When blocking a payee, a blocking reason may be supplied

  ## Examples

        iex> payee_status_update("somepayee", :blocked, "Business closed")
        :ok
  """
  @spec payee_status_update(Tipalti.idap(), :active | :suspended | :blocked, String.t() | nil) ::
          :ok | {:error, ClientError.t()} | {:error, RequestError.t()}
  def payee_status_update(idap, status, reason \\ nil) do
    status_string = status |> Atom.to_string() |> String.capitalize()

    run(
      "PayeeStatusUpdate",
      [idap: idap, status: status_string, reason: reason],
      [:payer_name, idap, :timestamp, status_string],
      {~x"//PayeeStatusUpdateResult", :empty}
    )
  end

  @doc """
  Not yet implemented
  """
  @spec payee_update_address :: {:error, :not_yet_implemented}
  def payee_update_address, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec payee_update_email :: {:error, :not_yet_implemented}
  def payee_update_email, do: {:error, :not_yet_implemented}

  @doc """
  Not yet implemented
  """
  @spec payments_between_dates :: {:error, :not_yet_implemented}
  def payments_between_dates, do: {:error, :not_yet_implemented}

  @doc """
  Updates a payee's basic info.

  If the payee does not exist, it will be created. The details must match the ones in the
  payee bank records. State can either be null, or a valid 2 letter US state. If skip_nulls=true the parameters with
  null values will be ignored. If skip_nulls=false the null values will overwrite existing values.
  Country is a 2 letter ISO 3166 code.

  Possible fields:
  *   first_name - string
  *   last_name - string
  *   street1 - string
  *   street2 - string
  *   city - string
  *   state - string
  *   zip - string
  *   country - string
  *   email - string
  *   company - string
  *   alias - string
  *   preferred_payer_entity - string
  *   ap_account_number - string
  *   payment_terms_id - string

  Required options:
  *   skip_nulls - boolean
  *   override_payable_country - boolean

  ## Examples

        iex> update_or_create_payee_info("newpayee", %{first_name: "John", last_name: "Smith"}, skip_nulls: true, override_payable_country: false)
        :ok

        iex> update_or_create_payee_info("invalidname", %{first_name: "José", last_name: "Valim"}, skip_nulls: true, override_payable_country: false)
        {:error, %Tipalti.ClientError{error_code: "ParameterError", error_message: "Invalid payee first name"}}
  """
  @spec update_or_create_payee_info(Tipalti.idap(), map(), keyword()) ::
          :ok | {:error, ClientError.t()} | {:error, RequestError.t()}
  def update_or_create_payee_info(idap, params, opts) do
    with {:ok, skip_nulls} <- get_required_opt(opts, :skip_nulls),
         {:ok, override_payable_country} <- get_required_opt(opts, :override_payable_country) do
      run(
        "UpdateOrCreatePayeeInfo",
        [
          idap: idap,
          skipNulls: skip_nulls,
          overridePayableCountry: override_payable_country,
          item: [
            FirstName: params[:first_name],
            LastName: params[:last_name],
            Street1: params[:street1],
            Street2: params[:street2],
            City: params[:city],
            State: params[:state],
            Zip: params[:zip],
            Country: params[:country],
            Email: params[:email],
            Company: params[:company],
            Alias: params[:alias],
            PreferredPayerEntity: params[:preferred_payer_entity],
            ApAccountNumber: params[:ap_account_number],
            PaymentTermsID: params[:payment_terms_id]
          ]
        ],
        [:payer_name, idap, :timestamp, params[:street1]],
        {~x"//UpdateOrCreatePayeeInfoResult", :empty}
      )
    end
  end

  @doc """
  Not yet implemented
  """
  @spec update_payee_custom_fields :: {:error, :not_yet_implemented}
  def update_payee_custom_fields, do: {:error, :not_yet_implemented}
end
