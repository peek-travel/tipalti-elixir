defmodule Tipalti.Config do
  @moduledoc false

  alias Tipalti.SystemTime

  def payer, do: get_env(:payer)

  def mode, do: get_env_atom(:mode, :sandbox)

  def master_key, do: get_env(:master_key)

  def build_hashkey(string), do: :sha256 |> :crypto.hmac(master_key(), string) |> Base.encode16(case: :lower)

  def timestamp, do: Application.get_env(:tipalti, :system_time_module, SystemTime).timestamp()

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
