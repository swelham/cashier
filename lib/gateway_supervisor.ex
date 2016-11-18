defmodule Cashier.GatewaySupervisor do
  use Supervisor

  @gateways [
    {:dummy, Cashier.Gateways.Dummy},
    {:paypal, Cashier.Gateways.PayPal}
  ]

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    children = 
      get_children()
      |> Enum.map(&map_to_worker/1)
    
    supervise(children, strategy: :one_for_one)
  end

  defp get_children do
    @gateways
      |> Enum.map(&map_child/1)
      |> Enum.filter(& &1 != nil)
  end

  defp map_child(gateway) do
    case Application.get_env(:cashier, elem(gateway, 0), nil) do
      nil -> nil
      config -> {gateway, config}
    end
  end

  defp map_to_worker({gateway, config}),
    do: worker(elem(gateway, 1), [%{config: config}])
end