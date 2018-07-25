defmodule Tipalti.Invoice do
  alias Tipalti.CustomField

  defmodule Line do
    @enforce_keys [:amount]
    defstruct amount: nil,
              description: nil,
              custom_fields: nil,
              line_type: nil,
              quantity: nil

    def from_map!(map) do
      struct!(__MODULE__, %{
        amount: Money.new!(map[:currency], map[:amount]),
        description: map[:description],
        custom_fields: CustomField.from_maps!(map[:custom_fields]),
        line_type: map[:line_type],
        quantity: map[:quantity]
      })
    end

    def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
  end

  defmodule Approver do
    @enforce_keys [:name, :email]
    defstruct name: nil,
              email: nil,
              order: nil

    def from_map!(map), do: struct!(__MODULE__, map)
    def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
  end

  @enforce_keys [:idap, :ref_code]
  defstruct idap: nil,
            ref_code: nil,
            date: nil,
            due_date: nil,
            line_items: nil,
            description: nil,
            can_approve: nil,
            internal_notes: nil,
            custom_fields: nil,
            is_paid_manually: nil,
            status: nil,
            approvers: nil,
            number: nil,
            approval_date: nil,
            payer_entity_name: nil,
            amount_due: nil

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

  def from_maps!(maps), do: Enum.map(maps, &from_map!/1)

  defp parse_date(nil), do: nil
  defp parse_date("0001-01-01T00:00:00"), do: nil
  defp parse_date(date_string), do: date_string |> NaiveDateTime.from_iso8601!() |> NaiveDateTime.to_date()
end
