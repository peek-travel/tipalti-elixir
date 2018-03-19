defmodule Tipalti.SystemTime do
  @moduledoc false

  def timestamp do
    DateTime.utc_now() |> DateTime.to_unix()
  end
end
