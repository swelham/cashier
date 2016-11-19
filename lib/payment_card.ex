defmodule Cashier.PaymentCard do
  defstruct [
    :holder,
    :brand,
    :number,
    :cvv,
    :expiry
  ]
end