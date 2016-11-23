defmodule Cashier.Gateways.Dummy do
  use Cashier.Gateways.Base, name: :dummy

  def authorize(_, _, _, _),
    do: respond("authorize")

  def capture(_, _, _, _),
    do: respond("capture")

  def purchase(_, _, _, _),
    do: respond("purchase")

  def refund(_, _, _),
    do: respond("refund")

  def void(_, _, _),
    do: respond("void")

  defp respond(key), do: {:ok, "#{key} from dummy_gateway"}
end