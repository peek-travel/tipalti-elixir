defmodule Tipalti.PayeeExtended do
  defmodule Properties do
    @enforce_keys [:idap]
    defstruct actual_payer_entity: nil,
              alias: nil,
              city: nil,
              company_name: nil,
              country: nil,
              email: nil,
              first_name: nil,
              idap: nil,
              last_name: nil,
              middle_name: nil,
              payable: nil,
              payment_currency: nil,
              payment_method: nil,
              phone: nil,
              portal_user: nil,
              preferred_payer_entity: nil,
              state: nil,
              status: nil,
              street1: nil,
              street2: nil,
              tax_form_entity_name: nil,
              tax_form_entity_type: nil,
              tax_form_status: nil,
              tax_form_type: nil,
              withholding_rate: nil,
              zip: nil

    def from_map!(map), do: struct!(__MODULE__, map)
  end

  alias Tipalti.CustomField

  @enforce_keys [:custom_fields, :properties]
  defstruct custom_fields: [], properties: nil

  def from_map!(%{properties: properties, custom_fields: custom_fields}) do
    struct!(
      __MODULE__,
      properties: Properties.from_map!(properties),
      custom_fields: CustomField.from_maps!(custom_fields)
    )
  end

  def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
end
