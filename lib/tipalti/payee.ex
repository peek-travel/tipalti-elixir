defmodule Tipalti.Payee do
  @moduledoc """
  Represents a simplified Tipalti Payee.
  """

  @type t :: %__MODULE__{
          address: String.t() | nil,
          alias: String.t() | nil,
          company_name: String.t() | nil,
          email: String.t() | nil,
          name: String.t() | nil,
          payment_method: String.t() | nil,
          payment_terms_id: String.t() | nil,
          payment_terms_name: String.t() | nil
        }

  defstruct [:address, :alias, :company_name, :email, :name, :payment_method, :payment_terms_id, :payment_terms_name]

  @doc false
  @spec from_map!(map()) :: t()
  def from_map!(map), do: struct!(__MODULE__, map)
end
