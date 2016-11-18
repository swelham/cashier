defmodule Cashier.Gateways.Dummy do
  use Cashier.Gateways.Base, name: :dummy

  def purchase do
    {:ok, "from dummy_gateway"}
  end
end