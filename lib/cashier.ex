defmodule Cashier do
  use Application
  # @gateways %{
  #   dummy: Cashier.Gateways.Dummy,
  #   paypal: Cashier.Gateways.PayPal
  # }

  def start(_type, _args),
    do: Cashier.Pipeline.PipelineSupervisor.start_link

  def authorize(amount, card),
    do: authorize(amount, card, default_opts)

  def authorize(amount, card, opts),
    do: send_event(opts, {:authorize, amount, card})

  def test(event), do: send_event(nil, event)

  defp send_event(opts, event) do
    Cashier.Pipeline.GatewayProducer.send_demand({self(), event})

    receive do
      {:ok, result} ->
        IO.inspect result
      _ ->
        IO.puts "something went wrong"
    end
  end

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

  # defp call(opts, args) do
  #   opts = merge_default_opts(opts)
  #   args = Tuple.append(args, opts)

  #   opts
  #     |> resolve_gateway
  #     |> start_gateway
  #     |> call_gateway(args)
  # end

  # defp start_gateway(nil),
  #   do: {:error, "A payment gateway was not specified"}
  # defp start_gateway({gateway, config}) do
  #   case @gateways[gateway] do
  #     nil ->
  #       {:error, "Unknown payment gateway was specified"}
  #     gateway ->
  #       GenServer.start_link(gateway, [config])
  #   end
  # end

  # defp call_gateway({:ok, gateway}, args),
  #   do: GenServer.call(gateway, args, gateway_timeout(gateway))
  # defp call_gateway(_, _),
  #   do: {:error, "The gateway failed to start"}

  # defp resolve_gateway(opts) do
  #   case Keyword.get(opts, :gateway) do
  #     nil -> nil
  #     gateway -> {gateway, gateway_config(gateway)}
  #   end
  # end

  # defp gateway_config(gateway),
  #   do: Application.get_env(:cashier, gateway, nil)

  # defp merge_default_opts(opts),
  #   do: Keyword.merge(default_opts, opts)

  # defp gateway_timeout(gateway),
  #   do: Application.get_env(:cashier, gateway)[:timeout] || default_timeout

  # defp default_timeout,
  #   do: get_default(:timeout) || 5000
end