use Mix.Config

config :tipalti,
  payer: "MyPayer",
  mode: :sandbox,
  master_key: "boguskey"

config :ex_money,
  default_cldr_backend: TipaltiElixir.Cldr
