defmodule Cashier do
  use Application

  def start(_type, _args) do
    Cashier.GatewaySupervisor.start_link()
  end

  def authorize(amount, card),
    do: authorize(amount, card, default_opts)

  def authorize(amount, card, opts) do
    opts
    |> resolve_gateway
    |> call({:authorize, amount, card, opts})
  end

  def capture(id, amount),
    do: capture(id, amount, default_opts)

  def capture(id, amount, opts) do
    opts
    |> resolve_gateway
    |> call({:capture, id, amount, opts})
  end

  def purchase(amount, card),
    do: purchase(amount, card, default_opts)

  def purchase(amount, card, opts) do
    opts
    |> resolve_gateway
    |> call({:purchase, amount, card, opts})
  end
  
  def refund(),
    do: refund(default_opts)

  def refund(opts) do
    opts
    |> resolve_gateway
    |> call({:refund})
  end
  
  def void(),
    do: void(default_opts)

  def void(opts) do
    opts
    |> resolve_gateway
    |> call({:void})
  end

  defp call(nil, _args),
    do: {:error, "A payment gateway was not specified"}
  defp call(gateway, args),
    do: GenServer.call(gateway, args, gateway_timeout(gateway))

  defp resolve_gateway([gateway: gateway]), do: gateway
  defp resolve_gateway(_), do: default_gateway 

  defp default_opts, do: [gateway: default_gateway]

  defp default_gateway,
    do: Application.get_env(:cashier, :cashier)[:default_gateway]
  
  defp gateway_timeout(gateway),
    do: Application.get_env(:cashier, gateway)[:timeout] || default_timeout

  defp default_timeout,
    do: Application.get_env(:cashier, :cashier)[:default_timeout] || 5000
end
