defmodule Cashier.TestGateway do
  use Cashier.Gateways.Base, name: :test_gateway

  def authorize,  do: respond("authorize")
  def capture,    do: respond("capture")
  def purchase,   do: respond("purchase")
  def refund,     do: respond("refund")
  def void,       do: respond("void")

  defp respond(key), do: {:ok, "#{key} from test_gateway"}
end