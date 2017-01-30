defmodule Cashier.Pipeline.PipelineSupervisor do
  use Supervisor

  @gateways [
    {:dummy, Cashier.Gateways.DummySupervisor},
    #{:paypal, Cashier.Gateways.PayPalSupervisor}
  ]

  def start_link,
    do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_opts) do
    children = [
      worker(Cashier.Pipeline.GatewayProducer, []),
      worker(Cashier.Pipeline.GatewayRouter, []),
      # TOOD: start up all configured gateway specific supervisors
      #worker(Cashier.Gateways.DummySupervisor, [])
    ] ++ get_gateway_supervisors

    supervise(children, strategy: :one_for_one)
  end

  defp get_gateway_supervisors do
     @gateways
      |> Enum.map(&map_child/1)
      |> Enum.filter(& &1 != nil)
      |> Enum.map(&map_to_worker/1)
  end

  defp map_child(gateway) do
    case Application.get_env(:cashier, elem(gateway, 0), nil) do
      nil -> nil
      config -> {gateway, config}
    end
  end

  defp map_to_worker({gateway, config}),
    do: worker(elem(gateway, 1), [config])
end