defmodule Tipalti.Balance do
  @moduledoc """
  Represents a Tipalti payer account balance.
  """

  @type t :: %__MODULE__{
          account_identifier: String.t(),
          balance: Money.t(),
          provider: String.t()
        }

  @enforce_keys [:account_identifier, :balance, :provider]
  defstruct [:account_identifier, :balance, :provider]

  @doc false
  @spec from_map!(map()) :: t()
  def from_map!(map) do
    struct!(__MODULE__, %{
      account_identifier: map[:account_identifier],
      balance: Money.new!(map[:currency], map[:balance]),
      provider: map[:provider]
    })
  end

  @doc false
  @spec from_maps!([map()]) :: [t()]
  def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
end
