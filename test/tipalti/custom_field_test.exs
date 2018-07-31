defmodule Tipalti.CustomFieldTest do
  use ExUnit.Case

  alias Tipalti.CustomField

  describe "from_map!/1" do
    test "creates a struct from the given map keys" do
      assert CustomField.from_map!(%{key: "foo", value: "bar"}) == %CustomField{key: "foo", value: "bar"}
    end
  end
end
