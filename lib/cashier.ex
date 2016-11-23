defmodule Cashier do
  use Application

  def start(_type, _args) do
    Cashier.GatewaySupervisor.start_link()
  end

  def authorize(amount, card),
    do: authorize(amount, card, default_opts)

  def authorize(amount, card, opts),
    do: call(opts, {:authorize, amount, card})

  def capture(id, amount),
    do: capture(id, amount, default_opts)

  def capture(id, amount, opts),
    do: call(opts, {:capture, id, amount})

  def purchase(amount, card),
    do: purchase(amount, card, default_opts)

  def purchase(amount, card, opts),
    do: call(opts, {:purchase, amount, card})
  
  def refund(id),
    do: refund(id, default_opts)

  def refund(id, opts),
    do: call(opts, {:refund, id})
  
  def void(id),
    do: void(id, default_opts)

  def void(id, opts),
    do: call(opts, {:void, id})

  defp call(opts, args) do
    opts = merge_default_opts(opts)
    args = Tuple.append(args, opts)

    opts
    |> resolve_gateway
    |> call_gateway(args)
  end

  defp call_gateway(nil, _args),
    do: {:error, "A payment gateway was not specified"}
  defp call_gateway(gateway, args),
    do: GenServer.call(gateway, args, gateway_timeout(gateway))

  defp resolve_gateway(opts),
    do: Keyword.get(opts, :gateway)

  defp merge_default_opts(opts),
  
    do: Keyword.merge(default_opts, opts)

  defp default_opts do
    [
      gateway: get_default(:gateway),
      currency: get_default(:currency)
    ]
  end

  defp get_default(key) do
    case Application.get_env(:cashier, :cashier)[:defaults] do
      nil -> nil
      defaults -> defaults[key]
    end
  end

  defp gateway_timeout(gateway),
    do: Application.get_env(:cashier, gateway)[:timeout] || default_timeout

  defp default_timeout,
    do: get_default(:timeout) || 5000
end
