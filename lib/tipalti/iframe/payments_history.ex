defmodule Tipalti.IFrame.PaymentsHistory do
  @moduledoc """
  Used to generate URLs to the Tipalti Payments History iFrame.
  """

  import Tipalti.IFrame

  @url %{
    sandbox: "https://ui2.sandbox.tipalti.com/PayeeDashboard/PaymentsHistory?",
    production: "https://ui2.tipalti.com/PayeeDashboard/PaymentsHistory?"
  }

  @doc """
  Generates a Payments History iFrame URL for the given payee id (idap).
  """
  @spec url(String.t()) :: URI.t()
  def url(idap) do
    build_url(@url, %{:idap => idap})
  end
end
