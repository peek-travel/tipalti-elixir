defmodule TestCldr do
  @moduledoc false

  use Cldr,
    default_locale: "en",
    locales: ["en"],
    providers: [Cldr.Number]
end
