defmodule Tipalti.IFrame.InvoiceHistory do
  @moduledoc """
  Used to generate URLs to the Tipalti Invoice History iFrame.
  """

  import Tipalti.Util

  @base_url %{
    sandbox: "https://ui2.sandbox.tipalti.com/PayeeDashboard/Invoices?",
    production: "https://ui2.tipalti.com/PayeeDashboard/Invoices?"
  }

  @doc """
  Generates an Invoice History iFrame URL for the given payee id (idap).
  """
  @spec generate_url(String.t()) :: URI.t()
  def generate_url(idap) do
    build_url(@base_url, %{:idap => idap})
  end
end
