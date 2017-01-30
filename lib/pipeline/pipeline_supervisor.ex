defmodule Cashier.Pipeline.PipelineSupervisor do
  use Supervisor

  def start_link,
    do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_opts) do
    children = [
      worker(Cashier.Pipeline.GatewayProducer, []),
      worker(Cashier.Pipeline.GatewayRouter, []),
      # TOOD: start up all configured gateway specific supervisors
      worker(Cashier.Gateways.DummySupervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end