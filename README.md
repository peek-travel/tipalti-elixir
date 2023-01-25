# Tipalti

[![CI Status](https://github.com/peek-travel/tipalti-elixir/workflows/CI/badge.svg)](https://github.com/peek-travel/tipalti-elixir/actions)
[![codecov](https://codecov.io/gh/peek-travel/tipalti-elixir/branch/master/graph/badge.svg)](https://codecov.io/gh/peek-travel/tipalti-elixir)
[![Hex.pm Version](https://img.shields.io/hexpm/v/tipalti.svg?style=flat)](https://hex.pm/packages/tipalti)
[![Inline docs](http://inch-ci.org/github/peek-travel/tipalti-elixir.svg)](http://inch-ci.org/github/peek-travel/tipalti-elixir)
[![License](https://img.shields.io/hexpm/l/tipalti.svg)](LICENSE.md)

[Tipalti](https://tipalti.com/) integration library for Elixir.

This library includes:

-   Payee and Payer SOAP API clients
-   iFrame integration helpers
-   IPN Router builder

> **NOTE**: Not all API functions have been implemented yet; this library is a work in progress.

## Installation

The package can be installed by adding `tipalti` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tipalti, "~> 0.9"}
  ]
end
```

## Configuration

There are 3 required configuration options for this library to work. See an example `config.exs` below:

```elixir
use Mix.Config

config :tipalti,
  payer: "MyPayer",
  mode: :sandbox,
  master_key: "boguskey"
```

Documentation can be found at <https://hexdocs.pm/tipalti>.
