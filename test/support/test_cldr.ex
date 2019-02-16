defmodule TestCldr do
  use Cldr,
    default_locale: "en",
    locales: ["en"],
    providers: [Cldr.Number]
end
