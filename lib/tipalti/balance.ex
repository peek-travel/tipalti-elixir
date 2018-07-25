defmodule Tipalti.Balance do
  @enforce_keys [:account_identifier, :balance, :provider]
  defstruct account_identifier: nil,
            balance: nil,
            provider: nil

  def from_map!(map) do
    struct!(__MODULE__, %{
      account_identifier: map[:account_identifier],
      balance: Money.new!(map[:currency], map[:balance]),
      provider: map[:provider]
    })
  end

  def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
end
