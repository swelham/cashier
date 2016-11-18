defmodule Cashier do
  use Application

  def start(_type, _args) do
    Cashier.GatewaySupervisor.start_link()
  end

  def authorize(),
    do: authorize(default_opts)

  def authorize(opts) do
    resolve_gateway(opts)
      |> call({:authorize})
  end

  def purchase(),
    do: purchase(default_opts)

  def purchase(opts) do
    resolve_gateway(opts)
      |> call({:purchase})
  end

  defp call(nil, _args),
    do: {:error, "A payment gateway was not specified"}
  defp call(gateway, args),
    do: GenServer.call(gateway, args)

  defp resolve_gateway([gateway: gateway]), do: gateway
  defp resolve_gateway(_), do: default_gateway 

  defp default_opts, do: [gateway: default_gateway]
  defp default_gateway,
    do: Application.get_env(:cashier, :cashier)[:default_gateway]

end
