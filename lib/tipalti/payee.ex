defmodule Tipalti.Payee do
  defstruct address: nil,
            alias: nil,
            company_name: nil,
            email: nil,
            name: nil,
            payment_method: nil,
            payment_terms_id: nil,
            payment_terms_name: nil

  def from_map!(map), do: struct!(__MODULE__, map)
end
