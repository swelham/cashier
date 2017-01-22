defmodule Cashier.TestGateway do
  use Cashier.Gateways.Base

  def authorize(_, _, _, _),
    do: respond("authorize")

  def capture(_, _, _, _),
    do: respond("capture")

  def purchase(_, _, _, _),
    do: respond("purchase")

  def refund(_, _, _),
    do: respond("refund")
  
  def store(_, _, _),
    do: respond("store")

  def unstore(_, _, _),
    do: respond("unstore")

  def void(_, _, _),
    do: respond("void")

  defp respond(key), do: {:ok, "#{key} from test_gateway"}
end