defmodule Cashier.Gateways.DummySupervisor do
  use ConsumerSupervisor

  def start_link do
    children = [
      worker(Cashier.Gateways.Dummy, [], restart: :temporary)
    ]

    ConsumerSupervisor.start_link(
      children,
      strategy: :one_for_one,
      subscribe_to: [{ Cashier.Pipeline.GatewayRouter, max_demand: 50}],
      name: __MODULE__)
  end
end