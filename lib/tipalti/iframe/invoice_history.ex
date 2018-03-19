defmodule Tipalti.IFrame.InvoiceHistory do
  @moduledoc """
  Generate URLs for the Tipalti Invoice History iFrame.
  """

  import Tipalti.IFrame, only: [build_url: 2]

  @url %{
    sandbox: URI.parse("https://ui2.sandbox.tipalti.com/PayeeDashboard/Invoices"),
    production: URI.parse("https://ui2.tipalti.com/PayeeDashboard/Invoices")
  }

  @doc """
  Generates an Invoice History iFrame URL for the given payee.

  ## Examples

      iex> url("mypayee")
      %URI{
        authority: "ui2.sandbox.tipalti.com",
        fragment: nil,
        host: "ui2.sandbox.tipalti.com",
        path: "/PayeeDashboard/Invoices",
        port: 443,
        query: "idap=mypayee&payer=MyPayer&ts=1521234048&hashkey=9413b4db4c08519497b6c236861049793e8834ac4de5e3cd866b7fec96e54eaa",
        scheme: "https",
        userinfo: nil
      }

      iex> url("mypayee") |> URI.to_string()
      "https://ui2.sandbox.tipalti.com/PayeeDashboard/Invoices?idap=mypayee&payer=MyPayer&ts=1521234048&hashkey=9413b4db4c08519497b6c236861049793e8834ac4de5e3cd866b7fec96e54eaa"
  """
  @spec url(Tipalti.idap()) :: URI.t()
  def url(idap) do
    build_url(@url, %{:idap => idap})
  end
end
