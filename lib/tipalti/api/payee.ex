defmodule Tipalti.API.Payee do
  import Tipalti.API

  @url %{
    sandbox: "https://api.sandbox.tipalti.com/v6/PayeeFunctions.asmx",
    production: "https://api.tipalti.com/v6/PayeeFunctions.asmx"
  }

  @get_payee_details %{
    name: "GetPayeeDetails",
    request: %{
      idap: {:required, :string, "idap"}
    },
    response: %{
      name: {:string, "Name"},
      address: {:string, "Address"},
      payment_method: {:string, "PaymentMethod"},
      email: {:string, "Email"}
    }
  }
  def get_payee_details(idap), do: run(@url, @get_payee_details, %{idap: idap}, idap: idap)

  @payee_payable %{
    name: "PayeePayable",
    request: %{
      idap: {:required, :string, "idap"},
      amount: {:required, :float, "amount"}
    },
    response: %{
      reason: {:string, "s"},
      payable: {:boolean, "b"}
    }
  }
  def payee_payable(idap, amount),
    do: run(@url, @payee_payable, %{idap: idap, amount: amount}, idap: idap, eat: :amount)

  @payee_payment_method %{
    name: "PayeePaymentMethod",
    request: %{
      idap: {:required, :string, "idap"}
    },
    response: %{
      payment_method: {:string, "s"}
    }
  }
  def payee_payment_method(idap), do: run(@url, @payee_payment_method, %{idap: idap}, idap: idap)
end
