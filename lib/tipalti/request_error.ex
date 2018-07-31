defmodule Tipalti.RequestError do
  @moduledoc """
  Represents a request error, which is either a server side HTTP error, or a failed request altogether.
  """

  @typedoc """
  All requests could result in this error.
  """
  @type t :: {:bad_http_response, integer()} | {:request_failed, any()}
end
