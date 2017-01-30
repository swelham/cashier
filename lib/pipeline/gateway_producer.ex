defmodule Cashier.Pipeline.GatewayProducer do
  use GenStage

  def start_link,
    do: GenStage.start_link(__MODULE__, [], name: __MODULE__)

  def send_demand(event) do
    GenStage.cast(__MODULE__, event)
  end

  def init(opts), do: {:producer, opts}

  def handle_cast(request, state) do
    {:noreply, [request], state}
  end

  def handle_demand(demand, state) do
    {:noreply, [demand], state}
  end
end