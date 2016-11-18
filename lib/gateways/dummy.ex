defmodule Cashier.Gateways.Dummy do
  use Cashier.Gateways.Base, name: :dummy

  def authorize,  do: respond
  def purchase,   do: respond

  defp respond, do: {:ok, "from dummy_gateway"}
end