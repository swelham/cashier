defmodule Cashier.TestGateway do
  use Cashier.Gateways.Base, name: :test_gateway

  def authorize(_, _, _, _),
    do: respond("authorize")

  def capture(_, _, _, _),
    do: respond("capture")

  def purchase(_, _, _, _),
    do: respond("purchase")

  def refund(_),
    do: respond("refund")

  def void(_, _, _),
    do: respond("void")

  defp respond(key), do: {:ok, "#{key} from test_gateway"}
end