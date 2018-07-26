defmodule Tipalti.Invoice do
  @moduledoc """
  Represents a Tipalti Invoice.
  """

  alias Tipalti.CustomField

  defmodule Line do
    @moduledoc """
    Represents a Tipalti Invoice Line.
    """

    @type t :: %__MODULE__{
            amount: Money.t(),
            description: String.t() | nil,
            custom_fields: [CustomField.t()],
            line_type: String.t() | nil,
            quantity: integer() | nil
          }

    @enforce_keys [:amount]
    defstruct [:amount, :description, :custom_fields, :line_type, :quantity]

    @doc false
    @spec from_map!(map()) :: t()
    def from_map!(map) do
      struct!(__MODULE__, %{
        amount: Money.new!(map[:currency], map[:amount]),
        description: map[:description],
        custom_fields: CustomField.from_maps!(map[:custom_fields]),
        line_type: map[:line_type],
        quantity: map[:quantity]
      })
    end

    @doc false
    @spec from_maps!([map()]) :: [t()]
    def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
  end

  defmodule Approver do
    @moduledoc """
    Represents a Tipalti Approver.
    """

    @type t :: %__MODULE__{
            name: String.t(),
            email: String.t(),
            order: integer() | nil
          }

    @enforce_keys [:name, :email]
    defstruct [:name, :email, :order]

    @doc false
    @spec from_map!(map()) :: t()
    def from_map!(map), do: struct!(__MODULE__, map)

    @doc false
    @spec from_maps!([map()]) :: [t()]
    def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
  end

  @type ref_code :: String.t()

  @type t :: %__MODULE__{
          idap: Tipalti.idap(),
          ref_code: ref_code(),
          date: Date.t() | nil,
          due_date: Date.t() | nil,
          line_items: [Line.t()],
          description: String.t() | nil,
          can_approve: boolean(),
          internal_notes: String.t() | nil,
          custom_fields: [CustomField.t()],
          is_paid_manually: boolean(),
          status: String.t(),
          approvers: [Approver.t()],
          number: String.t(),
          approval_date: Date.t() | nil,
          payer_entity_name: String.t(),
          amount_due: Money.t()
        }

  @enforce_keys [:idap, :ref_code, :can_approve, :is_paid_manually, :status, :number, :payer_entity_name, :amount_due]
  defstruct [
    :idap,
    :ref_code,
    :date,
    :due_date,
    :line_items,
    :description,
    :can_approve,
    :internal_notes,
    :custom_fields,
    :is_paid_manually,
    :status,
    :approvers,
    :number,
    :approval_date,
    :payer_entity_name,
    :amount_due
  ]

  @doc false
  @spec from_map!(map()) :: t()
  def from_map!(map) do
    struct!(__MODULE__, %{
      idap: map[:idap],
      ref_code: map[:ref_code],
      date: parse_date(map[:date]),
      due_date: parse_date(map[:due_date]),
      line_items: Line.from_maps!(map[:line_items]),
      description: map[:description],
      can_approve: map[:can_approve],
      internal_notes: map[:internal_notes],
      custom_fields: CustomField.from_maps!(map[:custom_fields]),
      is_paid_manually: map[:is_paid_manually],
      status: map[:status],
      approvers: Approver.from_maps!(map[:approvers]),
      number: map[:number],
      approval_date: parse_date(map[:approval_date]),
      payer_entity_name: map[:payer_entity_name],
      amount_due: Money.new!(map[:currency], map[:amount_due])
    })
  end

  @doc false
  @spec from_maps!([map()]) :: [t()]
  def from_maps!(maps), do: Enum.map(maps, &from_map!/1)

  @spec parse_date(String.t() | nil) :: Date.t() | nil
  defp parse_date(nil), do: nil
  defp parse_date("0001-01-01T00:00:00"), do: nil
  defp parse_date(date_string), do: date_string |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.to_date()
end
