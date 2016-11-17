defmodule Cashier.TestGateway do
  use Cashier.Gateways.Base, name: :test_gateway

  def purchase do
    {:ok, "from test_gateway"}
  end
end