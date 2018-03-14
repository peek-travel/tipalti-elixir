defmodule Tipalti.API.Payee do
  import Tipalti.API.SOAP.Client
  import SweetXml, only: [sigil_x: 2]

  @url %{
    sandbox: "https://api.sandbox.tipalti.com/v6/PayeeFunctions.asmx",
    production: "https://api.tipalti.com/v6/PayeeFunctions.asmx"
  }

  @get_payee_details %{
    name: "GetPayeeDetails",
    request: [
      idap: {:required, :string, "idap"}
    ],
    response: {
      ~x"//GetPayeeDetailsResult",
      name: ~x"./Name/text()"os,
      company_name: ~x"./CompanyName/text()"os,
      alias: ~x"./Alias/text()"os,
      address: ~x"./Address/text()"os,
      payment_method: ~x"./PaymentMethod/text()"os,
      email: ~x"./Email/text()"os,
      payment_terms_id: ~x"./PaymentTermsID/text()"os,
      payment_terms_name: ~x"./PaymentTermsName/text()"os
    }
  }
  def get_payee_details(idap), do: run(@url, @get_payee_details, %{idap: idap}, idap: idap)

  @payee_payable %{
    name: "PayeePayable",
    request: [
      idap: {:required, :string, "idap"},
      amount: {:required, :float, "amount"}
    ],
    response: {
      ~x"//PayeePayableResult",
      reason: ~x"./s/text()"os, payable: ~x"./b/text()"s
    }
  }
  def payee_payable(idap, amount),
    do: run(@url, @payee_payable, %{idap: idap, amount: amount}, idap: idap, eat: :amount)

  @payee_payment_method %{
    name: "PayeePaymentMethod",
    request: [
      idap: {:required, :string, "idap"}
    ],
    response: {
      ~x"//PayeePaymentMethodResult",
      payment_method: ~x"./s/text()"s
    }
  }
  def payee_payment_method(idap), do: run(@url, @payee_payment_method, %{idap: idap}, idap: idap)
end
