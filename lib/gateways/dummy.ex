defmodule Cashier.Gateways.Dummy do
  use Cashier.Gateways.Base, name: :dummy

  def authorize(_),
    do: respond("authorize")

  def capture(_),
    do: respond("capture")

  def purchase(_, _, _, _),
    do: respond("purchase")

  def refund(_),
    do: respond("refund")

  def void(_),
    do: respond("void")


  defp respond(key), do: {:ok, "#{key} from dummy_gateway"}
end