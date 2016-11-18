defmodule Cashier.Gateways.Dummy do
  use Cashier.Gateways.Base, name: :dummy

  def authorize,  do: respond("authorize")
  def capture,    do: respond("capture")
  def purchase,   do: respond("purchase")
  def refund,     do: respond("refund")
  def void,       do: respond("void")

  defp respond(key), do: {:ok, "#{key} from dummy_gateway"}
end