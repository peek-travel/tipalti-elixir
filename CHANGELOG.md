# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased][]

- No changes

## [0.10.0][]

### Fixed

- Make `can_approve` and `is_paid_manually` fields from Payer API required to match Tipalti specification

### Updated

- Updates on Tipalti documentation urls
## [0.9.0][] - 2021-05-20

### Updated

-   Fixes calls to :crypto.hmac/3 removed in OTP 24
-   Fixes / updates github actions
-   Updates all dependencies
-   Fixes warnings about :xmerl dependency
-   Upgrades to github native dependabot
-   Adds some missing test coverage to get back to 100% coverage

## [0.8.6][] - 2020-01-29

### Updated

-   Dependency updates
-   Use GitHub actions for CI

## [0.8.5][] - 2019-09-13

### Updated

-   Dependency updates

## [0.8.4][] - 2019-07-11

### Fixed

-   Fix handling of errors in CreateOrUpdateInvoices

## [0.8.3][] - 2019-06-15

### Updated

-   Dependency updates and credo refactors

## [0.8.2][] - 2019-02-19

### Fixed

-   Include `.formatter.exs` in hex package

## [0.8.1][] - 2019-02-19

### Fixed

-   Tipalti IPN events with type "bills" are translated to type "bill_updated"

## [0.8.0][] - 2019-02-15

### Added

-   Added a simple IPN router builder

## [0.7.0][] - 2019-01-04

### Changed

-   Update ex_money version to allow 3.1.

## [0.6.0][] - 2018-11-14

### Added

-   Configurable hackney recv_timeout with a default of 60 seconds.

## [0.5.1][] - 2018-11-12

### Fixed

-   Overly restrictive dialyzer typespecs

## [0.5.0][] - 2018-07-31

### Added

-   Payee API function: get_payee_invoices_changed_since_timestamp
-   Payer API function: get_payee_invoices_list_details

### Changed

-   Many function return values were changed:
    -   Error maps are structs now. e.g. `%{error_code: "...", error_message: "..."}` is now `%Tipalti.ClientError{error_code: "...", error_message: "..."}`
    -   A new `Tipalti.RequestError` struct will be returned for HTTP request errors
    -   `Payee.get_extended_payee_details_list/1` now returns `{:ok, [Tipalti.PayeeExtended.t()]}`
    -   `Payee.get_payee_details/1` now returns `{:ok, Tipalti.Payee.t()}`
    -   `Payee.payee_payable/2` now returns `{:ok, true}` or `{:ok, false, reason}`
    -   `Payee.payee_payment_method/1` now returns `{:ok, String.t()}`
    -   Any function that used to return `{:ok, :ok}` now just returns `:ok`
    -   `Payer.create_or_update_invoices` now returns the list of responses directly instead of wrapped in a map
    -   refer to the documentation for any additional details

## [0.4.0][] - 2018-05-05

### Added

-   Support passing in preferredPayerEntity parameter in setup iframe

## [0.3.0][] - 2018-06-12

### Updated

-   Updated several dependencies, including upgrading to tesla 1.0

## [0.2.0][] - 2018-05-03

### Added

-   Payer function CreateOrUpdateInvoices ([docs](https://hexdocs.pm/tipalti/Tipalti.API.Payer.html#create_or_update_invoices/0))

## 0.1.0 - 2018-04-26

### Initial release

[Unreleased]: https://github.com/peek-travel/tipalti-elixir/compare/0.10.0...HEAD

[0.10.0]: https://github.com/peek-travel/tipalti-elixir/compare/0.9.0...0.10.0

[0.9.0]: https://github.com/peek-travel/tipalti-elixir/compare/0.8.6...0.9.0

[0.8.6]: https://github.com/peek-travel/tipalti-elixir/compare/0.8.5...0.8.6

[0.8.5]: https://github.com/peek-travel/tipalti-elixir/compare/0.8.4...0.8.5

[0.8.4]: https://github.com/peek-travel/tipalti-elixir/compare/0.8.3...0.8.4

[0.8.3]: https://github.com/peek-travel/tipalti-elixir/compare/0.8.2...0.8.3

[0.8.2]: https://github.com/peek-travel/tipalti-elixir/compare/0.8.1...0.8.2

[0.8.1]: https://github.com/peek-travel/tipalti-elixir/compare/0.8.0...0.8.1

[0.8.0]: https://github.com/peek-travel/tipalti-elixir/compare/0.7.0...0.8.0

[0.7.0]: https://github.com/peek-travel/tipalti-elixir/compare/0.6.0...0.7.0

[0.6.0]: https://github.com/peek-travel/tipalti-elixir/compare/0.5.1...0.6.0

[0.5.1]: https://github.com/peek-travel/tipalti-elixir/compare/0.5.0...0.5.1

[0.5.0]: https://github.com/peek-travel/tipalti-elixir/compare/0.4.0...0.5.0

[0.4.0]: https://github.com/peek-travel/tipalti-elixir/compare/0.3.0...0.4.0

[0.3.0]: https://github.com/peek-travel/tipalti-elixir/compare/0.2.0...0.3.0

[0.2.0]: https://github.com/peek-travel/tipalti-elixir/compare/0.1.0...0.2.0
