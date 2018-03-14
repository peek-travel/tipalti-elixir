defmodule Tipalti.API.Payee do
  import Tipalti.API.SOAP.Client
  import SweetXml, only: [sigil_x: 2]

  @url %{
    sandbox: "https://api.sandbox.tipalti.com/v6/PayeeFunctions.asmx",
    production: "https://api.tipalti.com/v6/PayeeFunctions.asmx"
  }

  def get_payee_details(idap) do
    run(@url, "GetPayeeDetails", [idap: idap], [:payer_name, idap, :timestamp], {
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

  def payee_payable(idap, amount \\ 100.0) do
    run(
      @url,
      "PayeePayable",
      [idap: idap, amount: amount],
      [:payer_name, idap, :timestamp, {:float, amount}],
      # TODO: payable is a boolean
      {~x"//PayeePayableResult", reason: ~x"./s/text()"os, payable: ~x"./b/text()"s}
    )
  end

  def payee_payment_method(idap) do
    run(
      @url,
      "PayeePaymentMethod",
      [idap: idap],
      [:payer_name, idap, :timestamp],
      {~x"//PayeePaymentMethodResult", payment_method: ~x"./s/text()"s}
    )
  end

  def update_or_create_payee_info(idap, params, opts) do
    with {:ok, skip_nulls} <- get_required_opt(opts, :skip_nulls),
         {:ok, override_payable_country} <- get_required_opt(opts, :override_payable_country) do
      run(
        @url,
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

  defp get_required_opt(opts, key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} ->
        {:ok, value}

      :error ->
        {:error, {:missing_required_option, key}}
    end
  end
end
