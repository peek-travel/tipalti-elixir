use Mix.Config

config :ex_money,
  default_cldr_backend: TestCldr

config :tipalti,
  payer: "MyPayer",
  mode: :sandbox,
  master_key: "boguskey"
