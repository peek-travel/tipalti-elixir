# Used by "mix format"
locals_without_parens = [on: 2]

[
  inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:tesla],
  line_length: 120,
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
