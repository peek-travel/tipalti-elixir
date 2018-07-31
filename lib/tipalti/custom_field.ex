defmodule Tipalti.CustomField do
  @moduledoc """
  Represents a Tipalti custom field key/value pair.
  """

  @type t :: %__MODULE__{
          key: String.t(),
          value: String.t() | nil
        }

  @enforce_keys [:key]
  defstruct [:key, :value]

  @doc false
  @spec from_map!(map()) :: t()
  def from_map!(map), do: struct!(__MODULE__, map)

  @doc false
  @spec from_maps!([map()]) :: [t()]
  def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
end
