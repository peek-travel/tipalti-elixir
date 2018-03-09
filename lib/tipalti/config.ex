defmodule Tipalti.Config do
  @moduledoc false

  @doc false
  @spec payer() :: String.t() | nil
  def payer, do: get_env(:payer)

  @doc false
  @spec mode() :: atom() | nil
  def mode, do: get_env_atom(:mode, :sandbox)

  @doc false
  @spec master_key() :: String.t() | nil
  def master_key, do: get_env(:master_key)

  @doc false
  @spec build_hashkey(String.t()) :: String.t()
  def build_hashkey(string), do: :sha256 |> :crypto.hmac(master_key(), string) |> Base.encode16(case: :lower)

  @doc false
  def timestamp, do: DateTime.utc_now() |> DateTime.to_unix()

  defp get_env_atom(key, default) do
    case get_env(key, default) do
      nil ->
        nil

      value when is_atom(value) ->
        value

      value when is_binary(value) ->
        String.to_existing_atom(value)
    end
  end

  defp get_env(key, default \\ nil) do
    case Application.get_env(:tipalti, key, default) do
      {:system, var} ->
        System.get_env(var)

      value ->
        value
    end
  end
end
