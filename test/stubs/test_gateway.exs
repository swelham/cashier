defmodule Cashier.Gateways.Test do
  use Cashier.Gateways.BaseSupervisor,
    module: __MODULE__,
    name: :test
    
  use Cashier.Gateways.Base

  def authorize(_, _, _),
    do: respond("authorize")

  def capture(_, _, _),
    do: respond("capture")

  def purchase(_, _, _),
    do: respond("purchase")

  def refund(_, _),
    do: respond("refund")

  def store(_, _),
    do: respond("store")

  def unstore(_, _),
    do: {:ok, {:test, "raw_data"}}

  def void(_, _),
    do: respond("void")

  defp respond(key), do: {:ok, "#{key}_id", {:test, "raw_data"}}
end