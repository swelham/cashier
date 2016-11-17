defmodule Cashier.Gateways.Bogus do
  use Cashier.Gateways.Base, name: :bogus

  def purchase do
    {:ok, "from bogus"}
  end
end