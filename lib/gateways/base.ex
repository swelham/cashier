defmodule Cashier.Gateways.Base do
  defmacro __using__(opts) do
    quote do
      def start_link,
        do: start_link([])

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: unquote(opts[:name]))
      end

      def handle_call({:authorize, amount, card, opts}, _from, state),
        do: {:reply, authorize(amount, card, opts, state), state}

      def handle_call({:capture}, _from, state),
        do: {:reply, capture(state), state}

      def handle_call({:purchase, amount, card, opts}, _from, state),
        do: {:reply, purchase(amount, card, opts, state), state}
      
      def handle_call({:refund}, _from, state),
        do: {:reply, refund(state), state}
      
      def handle_call({:void}, _from, state),
        do: {:reply, void(state), state}

      # overridable functions
      def init(opts), do: {:ok, opts}
      
      def authorize(amount, card, opts, state),
        do: :not_implemented

      def capture(state),
        do: :not_implemented
      
      def purchase(amount, card, opts, state),
        do: :not_implemented

      def refund(state),
        do: :not_implemented

      def void(state),
        do: :not_implemented

      defoverridable [
        init: 1,
        authorize: 4,
        capture: 1,
        purchase: 4,
        refund: 1,
        void: 1
      ]
    end
  end
end