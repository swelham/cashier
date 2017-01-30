defmodule Cashier do
  use Application

  def start(_type, _args),
    do: Cashier.Pipeline.PipelineSupervisor.start_link

  def authorize(amount, card),
    do: authorize(amount, card, default_opts)
  def authorize(amount, card, opts),
    do: send_event(opts, {:authorize, amount, card})

  def capture(id, amount),
    do: capture(id, amount, default_opts)
  def capture(id, amount, opts),
    do: send_event(opts, {:capture, id, amount})

  def purchase(amount, card),
    do: purchase(amount, card, default_opts)
  def purchase(amount, card, opts),
    do: send_event(opts, {:purchase, amount, card})
    
  def refund(id),
    do: refund(id, default_opts)
  def refund(id, opts),
    do: send_event(opts, {:refund, id})

  def store(card),
    do: store(card, default_opts)
  def store(card, opts),
    do: send_event(opts, {:store, card})

  def unstore(id),
    do: unstore(id, default_opts)
  def unstore(id, opts),
    do: send_event(opts, {:unstore, id})

  def void(id),
    do: void(id, default_opts)
  def void(id, opts),
    do: send_event(opts, {:void, id})

  defp send_event(opts, event) do
    Cashier.Pipeline.GatewayProducer.send_demand({self(), event, opts})

    receive do
      {:ok, data} ->
        data
      _ -> # todo: add some proper error handling when there are process issues
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