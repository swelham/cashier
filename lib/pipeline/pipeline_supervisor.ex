defmodule Cashier.Pipeline.PipelineSupervisor do
  use Supervisor

  @gateways [
    dummy: Cashier.Gateways.Dummy.Supervisor,
    paypal: Cashier.Gateways.PayPal.Supervisor
  ]

  def start_link,
    do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_opts) do
    children = [
      worker(Cashier.Pipeline.GatewayProducer, []),
      worker(Cashier.Pipeline.GatewayRouter, [])
    ] ++ get_gateway_supervisors()

    supervise(children, strategy: :one_for_one)
  end

  defp get_gateway_supervisors do
     @gateways
      |> Enum.map(&map_child/1)
      |> Enum.filter(& &1 != nil)
      |> Enum.map(&map_to_worker/1)
  end

  defp map_child({gateway, mod}) do
    case Application.get_env(:cashier, gateway, nil) do
      nil -> nil
      config -> {mod, config}
    end
  end

  defp map_to_worker({mod, config}),
    do: worker(mod, [config])
end