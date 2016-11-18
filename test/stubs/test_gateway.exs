defmodule Cashier.TestGateway do
  use Cashier.Gateways.Base, name: :test_gateway

  def authorize,  do: respond
  def purchase,   do: respond

  defp respond, do: {:ok, "from test_gateway"}
end