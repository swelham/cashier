defmodule Cashier.Gateways.Dummy do
  def start_link({pid, data, opts}) do
    Task.start_link(fn -> 
      send(pid, {:ok, call(data, opts)})
    end)
  end

  def call({:authorize, amount, card}, opts),
    do: authorize(amount, card, opts)
    
  def call({:capture, id, amount}, opts),
    do: capture(id, amount, opts)

  def call({:purchase, amount, card}, opts),
    do: purchase(amount, card, opts)

  def call({:refund, id}, opts),
    do: refund(id, opts)

  def call({:store, card}, opts),
    do: store(card, opts)

  def call({:unstore, id}, opts),
    do: unstore(id, opts)

  def call({:void, id}, opts),
    do: void(id, opts)

  def authorize(_, _, _),
    do: respond("authorize")

  def capture(_, _, _),
    do: respond("capture")

  def purchase(_, _, _),
    do: respond("purchase")

  def refund(_, _),
    do: respond("refund")

  def store(_, _),
    do: respond("store")

  def unstore(_, _),
    do: {:ok, {:dummy, "raw_data"}}

  def void(_, _),
    do: respond("void")

  defp respond(key), do: {:ok, "#{key}_id", {:dummy, "raw_data"}}
end