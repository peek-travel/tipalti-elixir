defmodule Tipalti.Invoice.ApproverTest do
  use ExUnit.Case

  alias Tipalti.Invoice.Approver

  describe "from_map!/1" do
    test "creates a struct from the given map keys" do
      assert Approver.from_map!(%{name: "foo", email: "foo@bar.com"}) == %Approver{
               name: "foo",
               email: "foo@bar.com",
               order: nil
             }
    end
  end
end
