defmodule Cashier do
  use Application

  def start(_type, _args) do
    Cashier.GatewaySupervisor.start_link()
  end

  def purchase(),
    do: purchase([gateway: default_gateway])

  def purchase(opts) do
    gateway = opts[:gateway] || default_gateway

    call(gateway, {:purchase})
  end

  defp call(nil, _args),
    do: {:error, "A payment gateway was not specified"}
  defp call(gateway, args),
    do: GenServer.call(gateway, args)

  defp default_gateway do
    Application.get_env(:cashier, :cashier)[:default_gateway]
  end
end
