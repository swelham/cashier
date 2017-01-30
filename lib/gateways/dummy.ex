defmodule Cashier.Gateways.Dummy do
  def start_link({pid, data, opts}) do
    Task.start_link(fn -> 
      send(pid, {:ok, call(data, opts)})
    end)
  end

  def call({:authorize, amount, card}, opts),
    do: authorize(card, amount, opts)

  def authorize(_card, _amount, _opts) do
    {:ok, "authorize_id", {:dummy, "raw_data"}}
  end
end