defmodule Tipalti.ConfigTest do
  use ExUnit.Case

  alias Tipalti.Config

  describe "mode/0" do
    test "returns mode as atom when configured as string" do
      Application.put_env(:tipalti, :mode, "sandbox")

      assert Config.mode() == :sandbox
    end

    test "returns mode as atom when configured as env var" do
      System.put_env("TIPALTI_MODE", "sandbox")
      Application.put_env(:tipalti, :mode, {:system, "TIPALTI_MODE"})

      assert Config.mode() == :sandbox
    end
  end
end
