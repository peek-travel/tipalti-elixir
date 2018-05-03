defmodule Tipalti.IFrame.SetupProcess do
  @moduledoc """
  Generate URLs for the Tipalti Setup Process iFrame.
  """

  import Tipalti.IFrame, only: [build_url: 3]

  @type flaggable_fields ::
          :country
          | :first
          | :middle
          | :last
          | :company
          | :street1
          | :street2
          | :city
          | :zip
          | :state
          | :email

  @typedoc """
  These are the fields that are "forcable", meaning that a value supplied for them will override any value that may
  already exist for the account.
  """
  @type forcable_fields :: flaggable_fields

  @typedoc """
  These fields you can mark as "read-only"; they will appear in the setup form, but not be changable.
  """
  @type read_onlyable_fields :: flaggable_fields

  @type option :: {:force, [forcable_fields]} | {:read_only, [read_onlyable_fields]}
  @type options :: [option]

  @typedoc """
  Struct used to represent params to the Tipalti Setup Process iFrame.

  ## Fields:

    * `:idap` - Payee ID
    * `:country` - ISO 3166 2-letter country code
    * `:first` - Name of payee
    * `:middle` - Name of payee
    * `:last` - Name of payee
    * `:company` - Company name
    * `:uiculture` - Language code; one of (ar, zh-CHS, en, fr, de, it, ja, ko, nl, pt-BR, ru, es, vi)
    * `:street1` - The payee contact address details
    * `:street2` - The payee contact address details
    * `:city` - The payee contact address details
    * `:zip` - The payee contact address details
    * `:state` - The payee contact address details
    * `:alias` - An alternate name for the payee, if applicable
    * `:email` - The payee email address
    * `:force` - A list of fields you'd like to force (override the value even if a value already exists for the account)
    * `:read_only` - A list of fields you'd like to make read-only
  """
  @type t :: %__MODULE__{
          idap: Tipalti.idap(),
          country: String.t(),
          first: String.t(),
          middle: String.t(),
          last: String.t(),
          company: String.t(),
          uiculture: String.t(),
          street1: String.t(),
          street2: String.t(),
          city: String.t(),
          zip: String.t(),
          state: String.t(),
          alias: String.t(),
          email: String.t()
        }

  @enforce_keys [:idap]
  defstruct idap: nil,
            country: nil,
            first: nil,
            middle: nil,
            last: nil,
            company: nil,
            uiculture: nil,
            street1: nil,
            street2: nil,
            city: nil,
            zip: nil,
            state: nil,
            alias: nil,
            email: nil

  @url %{
    sandbox: URI.parse("https://ui2.sandbox.tipalti.com/PayeeDashboard/Home"),
    production: URI.parse("https://ui2.tipalti.com/PayeeDashboard/Home")
  }

  @doc """
  Generates a Setup Process iFrame URL for the given struct of parameters.

  ## Examples

      iex> params = %Tipalti.IFrame.SetupProcess{idap: "mypayee"}
      ...> url(params)
      %URI{
        authority: "ui2.sandbox.tipalti.com",
        fragment: nil,
        host: "ui2.sandbox.tipalti.com",
        path: "/PayeeDashboard/Home",
        port: 443,
        query: "idap=mypayee&payer=MyPayer&ts=1521234048&hashkey=9413b4db4c08519497b6c236861049793e8834ac4de5e3cd866b7fec96e54eaa",
        scheme: "https",
        userinfo: nil
      }

      iex> params = %Tipalti.IFrame.SetupProcess{idap: "mypayee", company: "My Company", first: "Joe"}
      ...> url(params, force: [:company], read_only: [:first]) |> URI.to_string()
      "https://ui2.sandbox.tipalti.com/PayeeDashboard/Home?first=Joe&firstSetReadOnly=TRUE&forceCompany=My+Company&idap=mypayee&payer=MyPayer&ts=1521234048&hashkey=78f5d8126f299fd2f80024cc00bccf2b43bae28987eb0a3b44d5d8d4bece7f14"
  """
  @spec url(t(), options()) :: URI.t()
  def url(struct, opts \\ []) do
    params = Map.from_struct(struct)
    build_url(@url, params, opts)
  end
end
