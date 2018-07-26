defmodule Tipalti.PayeeExtended do
  @moduledoc """
  Represents a detailed Tipalti Payee.
  """

  defmodule Properties do
    @moduledoc """
    Represents the properties of a detailed Tipalti Payee.
    """

    @type t :: %__MODULE__{
            actual_payer_entity: String.t() | nil,
            alias: String.t() | nil,
            city: String.t() | nil,
            company_name: String.t() | nil,
            country: String.t() | nil,
            email: String.t() | nil,
            first_name: String.t() | nil,
            idap: String.t(),
            last_name: String.t() | nil,
            middle_name: String.t() | nil,
            payable: boolean(),
            payment_currency: String.t() | nil,
            payment_method: String.t() | nil,
            phone: String.t() | nil,
            portal_user: String.t() | nil,
            preferred_payer_entity: String.t() | nil,
            state: String.t() | nil,
            status: String.t() | nil,
            street1: String.t() | nil,
            street2: String.t() | nil,
            tax_form_entity_name: String.t() | nil,
            tax_form_entity_type: String.t() | nil,
            tax_form_status: String.t() | nil,
            tax_form_type: String.t() | nil,
            withholding_rate: String.t() | nil,
            zip: String.t() | nil
          }

    @enforce_keys [:idap, :payable]
    defstruct [
      :actual_payer_entity,
      :alias,
      :city,
      :company_name,
      :country,
      :email,
      :first_name,
      :idap,
      :last_name,
      :middle_name,
      :payable,
      :payment_currency,
      :payment_method,
      :phone,
      :portal_user,
      :preferred_payer_entity,
      :state,
      :status,
      :street1,
      :street2,
      :tax_form_entity_name,
      :tax_form_entity_type,
      :tax_form_status,
      :tax_form_type,
      :withholding_rate,
      :zip
    ]

    @doc false
    @spec from_map!(map()) :: t()
    def from_map!(map), do: struct!(__MODULE__, map)
  end

  alias Tipalti.CustomField

  @type t :: %__MODULE__{
          custom_fields: [CustomField.t()],
          properties: Properties.t()
        }

  @enforce_keys [:custom_fields, :properties]
  defstruct custom_fields: [], properties: nil

  @doc false
  @spec from_map!(map()) :: t()
  def from_map!(%{properties: properties, custom_fields: custom_fields}) do
    struct!(
      __MODULE__,
      properties: Properties.from_map!(properties),
      custom_fields: CustomField.from_maps!(custom_fields)
    )
  end

  @doc false
  @spec from_maps!([map()]) :: [t()]
  def from_maps!(maps), do: Enum.map(maps, &from_map!/1)
end
