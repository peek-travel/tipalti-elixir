defmodule Tipalti.API.Payee do
  @moduledoc """
  Obtain or update payee info.

  Details are taken from: http://api.qa.payrad.com/v7/PayeeFunctions.asmx
  """

  import SweetXml, only: [sigil_x: 2]

  @version "v7"

  use Tipalti.API,
    url: [
      sandbox: "https://api.sandbox.tipalti.com/#{@version}/PayeeFunctions.asmx",
      production: "https://api.tipalti.com/#{@version}/PayeeFunctions.asmx"
    ],
    standard_response: [
      ok_code: "OK",
      error_paths: [error_code: ~x"./errorCode/text()"s, error_message: ~x"./errorMessage/text()"os]
    ]

  @typedoc """
  All Payee API responses are of this form.

  Errors are not really standardized yet.
  """
  @type payee_response :: {:ok, map() | :ok} | {:error, any()}

  # TODO: CancelInvoice

  # TODO: ClosePayeeAccount

  # TODO: CreatePayeeInfoAutoIdap

  # TODO: GetExtendedPayeeDetails

  # TODO: GetExtendedPayeeDetailsList

  # TODO: GetExtendedPODetails

  # TODO: GetExtendedPODetailsList

  # TODO: GetInvoicesPayableAmount

  @doc """
  Returns details of a given payee.

  Included details are:
  *   name
  *   company_name
  *   alias
  *   address
  *   payment_method
  *   email
  *   payment_terms_id
  *   payment_terms_name

  ## Examples

        iex> get_payee_details("somepayee")
        {:ok,
          %{
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
        {:error, %{error_code: "PayeeUnknown", error_message: "PayeeUnknown"}}
  """
  @spec get_payee_details(Tipalti.idap()) :: payee_response()
  def get_payee_details(idap) do
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
    })
  end

  # TODO: GetPayeeInvoiceList

  # TODO: GetPayeeInvoicesChangedSinceTimestamp

  # TODO: GetPayeePendingInvoiceTotal

  # TODO: GetPayeesChangedSinceTimestamp

  # TODO: GetPODetails

  @doc """
  Return payable status of payee.

  If a payment request were to be issued, the payee might not get paid.
  Possible reasons for not being paid are - missing tax documents, payment below threshold, account locked, address
  missing, or other. Returns true if payable. If false, the reason for not being payable will be included.

  ## Examples

        iex> payee_payable("payablepayee", 100)
        {:ok, %{payable: true, reason: nil}}

        iex> payee_payable("unpayablepayee")
        {:ok, %{payable: false, reason: "Tax,No PM"}}

        iex> payee_payable("badpayee", 123.45)
        {:error, %{error_code: "PayeeUnknown", error_message: "PayeeUnknown"}}
  """
  @spec payee_payable(Tipalti.idap(), integer() | float()) :: payee_response()
  def payee_payable(idap, amount \\ 100.0) do
    run(
      "PayeePayable",
      [idap: idap, amount: amount],
      [:payer_name, idap, :timestamp, {:float, amount}],
      {~x"//PayeePayableResult", reason: ~x"./s/text()"os, payable: ~x"./b/text()"b}
    )
  end

  @doc """
  Returns the name of the payee's selected payment method.

  ## Examples

        iex> payee_payment_method("payablepayee")
        {:ok, %{payment_method: "Check"}}

        iex> payee_payment_method("unpayablepayee")
        {:ok, %{payment_method: "No payment method"}}

        iex> payee_payment_method("badpayee")
        {:error, %{error_code: "PayeeUnknown", error_message: "PayeeUnknown"}}
  """
  @spec payee_payment_method(Tipalti.idap()) :: payee_response()
  def payee_payment_method(idap) do
    run(
      "PayeePaymentMethod",
      [idap: idap],
      [:payer_name, idap, :timestamp],
      {~x"//PayeePaymentMethodResult", payment_method: ~x"./s/text()"s}
    )
  end

  # TODO: PayeeStatusUpdate

  # TODO: PayeeUpdateAddress

  # TODO: PayeeUpdateEmail

  # TODO: PaymentsBetweenDates

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
        {:ok, :ok}

        iex> update_or_create_payee_info("invalidname", %{first_name: "José", last_name: "Valim"}, skip_nulls: true, override_payable_country: false)
        {:error, %{error_code: "ParameterError", error_message: "Invalid payee first name"}}
  """
  @spec update_or_create_payee_info(Tipalti.idap(), map(), keyword()) :: payee_response()
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

  # TODO: UpdatePayeeCustomFields
end
