defmodule Tipalti.ClientError do
  @moduledoc """
  Represents a Tipalti client error.
  """

  @typedoc """
  A malformed client request could result in this error.
  """
  @type t :: %__MODULE__{
          error_code: String.t(),
          error_message: String.t()
        }

  @enforce_keys [:error_code, :error_message]
  defstruct error_code: nil,
            error_message: nil

  @doc false
  @spec from_map!(map()) :: t()
  def from_map!(map) do
    struct!(__MODULE__, %{
      error_code: map[:error_code],
      error_message: map[:error_message]
    })
  end
end
