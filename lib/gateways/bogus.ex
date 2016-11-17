defmodule Cashier.Gateways.Bogus do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :bogus)
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle_call({:purchase}, _from, state) do
    {:reply, {:ok, "from bogus"}, state}
  end
end