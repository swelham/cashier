defmodule Cashier.Address do
  defstruct [
    :line1,
    :line2,
    :city,
    :state,
    :country_code,
    :postal_code
  ]
end