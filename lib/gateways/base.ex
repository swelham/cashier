defmodule Cashier.Gateways.Base do
  defmacro __using__(opts) do
    quote do
      def start_link,
        do: start_link([])

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: unquote(opts[:name]))
      end

      def handle_call({:authorize}, _from, state) do
        {:reply, authorize(), state}
      end

      def handle_call({:purchase}, _from, state) do
        {:reply, purchase(), state}
      end

      # overridable functions

      def init(opts), do: {:ok, opts}
      
      def authorize(), do: :not_implemented

      def purchase(), do: :not_implemented

      defoverridable [init: 1, authorize: 0, purchase: 0]
    end
  end
end