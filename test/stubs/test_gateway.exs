defmodule Cashier.TestGateway do
  use Cashier.Gateways.Base, name: :test_gateway

  def authorize(_),  do: respond("authorize")
  def capture(_),    do: respond("capture")
  def purchase(_),   do: respond("purchase")
  def refund(_),     do: respond("refund")
  def void(_),       do: respond("void")

  defp respond(key), do: {:ok, "#{key} from test_gateway"}
end