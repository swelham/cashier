defmodule Cashier.Gateways.Base do
  defmacro __using__(opts) do
    quote do
      def start_link,
        do: start_link([])

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: unquote(opts[:name]))
      end

      def handle_call({:authorize}, _from, state),
        do: {:reply, authorize(), state}

      def handle_call({:capture}, _from, state),
        do: {:reply, capture(), state}

      def handle_call({:purchase}, _from, state),
        do: {:reply, purchase(), state}
      
      def handle_call({:refund}, _from, state),
        do: {:reply, refund(), state}
      
      def handle_call({:void}, _from, state),
        do: {:reply, void(), state}

      # overridable functions
      def init(opts), do: {:ok, opts}
      
      def authorize,  do: :not_implemented
      def capture,    do: :not_implemented
      def purchase,   do: :not_implemented
      def refund,     do: :not_implemented
      def void,       do: :not_implemented

      defoverridable [
        init: 1,
        authorize: 0,
        capture: 0,
        purchase: 0,
        refund: 0,
        void: 0
      ]
    end
  end
end