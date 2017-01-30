defmodule Cashier.Gateways.Dummy do
  def start_link({:sendit, {pid, data}}) do
    Task.start_link(fn -> 
      Process.sleep(4000)

      send(pid, {:ok, data})
    end)
  end
end