defmodule Tipalti.IFrame.InvoiceHistory do
  @moduledoc """
  Used to generate URLs to the Tipalti Invoice History iFrame.
  """

  import Tipalti.IFrame

  @url %{
    sandbox: "https://ui2.sandbox.tipalti.com/PayeeDashboard/Invoices?",
    production: "https://ui2.tipalti.com/PayeeDashboard/Invoices?"
  }

  @doc """
  Generates an Invoice History iFrame URL for the given payee id (idap).
  """
  @spec url(String.t()) :: URI.t()
  def url(idap) do
    build_url(@url, %{:idap => idap})
  end
end
