# Used by "mix format"
[
  inputs: ["mix.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:tesla],
  line_length: 120,
  locals_without_parens: [
    # TODO: remove this when tesla exports formatter config
    adapter: 1,
    adapter: 2,
    plug: 2
  ]
]
