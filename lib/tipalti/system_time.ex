defmodule Tipalti.SystemTime do
  @moduledoc false

  @spec timestamp :: integer()
  def timestamp do
    DateTime.utc_now() |> DateTime.to_unix()
  end
end
