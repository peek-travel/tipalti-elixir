defmodule Tipalti.SystemTimeTest do
  use ExUnit.Case

  alias Tipalti.SystemTime

  test "timestamp" do
    ts1 = DateTime.utc_now() |> DateTime.to_unix()
    ts2 = SystemTime.timestamp()

    # the timestamp will be within 1 second of the one we generated
    assert ts1 == ts2 || ts1 == ts2 + 1
  end
end
