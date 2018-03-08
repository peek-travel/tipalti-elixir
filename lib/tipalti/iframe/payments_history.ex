defmodule Tipalti.IFrame.PaymentsHistory do
  @moduledoc """
  Used to generate URLs to the Tipalti Payments History iFrame.
  """

  import Tipalti.Util

  @base_url %{
    sandbox: "https://ui2.sandbox.tipalti.com/PayeeDashboard/PaymentsHistory?",
    production: "https://ui2.tipalti.com/PayeeDashboard/PaymentsHistory?"
  }

  @doc """
  Generates a Payments History iFrame URL for the given payee id (idap).
  """
  @spec generate_url(String.t()) :: URI.t()
  def generate_url(idap) do
    build_url(@base_url, %{:idap => idap})
  end
end
