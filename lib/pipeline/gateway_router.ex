defmodule Cashier.Pipeline.GatewayRouter do
  use GenStage

  def start_link,
    do: GenStage.start_link(__MODULE__, [], name: __MODULE__)

  def init(opts),
    do: {:producer_consumer, opts, dispatcher: GenStage.BroadcastDispatcher, subscribe_to: [Cashier.Pipeline.GatewayProducer]}

  def handle_events(demand, _from, state),
    do: {:noreply, demand, state}
end