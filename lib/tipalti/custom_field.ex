defmodule Tipalti.CustomField do
  @enforce_keys [:key]
  defstruct key: nil, value: nil

  def from_map!(map), do: struct!(__MODULE__, map)
  def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
end
