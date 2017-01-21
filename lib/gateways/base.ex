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

      def handle_call({:capture, id, amount, opts}, _from, state),
        do: {:reply, capture(id, amount, opts, state), state}

      def handle_call({:purchase, amount, card, opts}, _from, state),
        do: {:reply, purchase(amount, card, opts, state), state}
      
      def handle_call({:refund, id, opts}, _from, state),
        do: {:reply, refund(id, opts, state), state}
      
      def handle_call({:store, card, opts}, _from, state),
        do: {:reply, store(card, opts, state), state}

      def handle_call({:unstore, id, opts}, _from, state),
        do: {:reply, unstore(id, opts, state), state}

      def handle_call({:void, id, opts}, _from, state),
        do: {:reply, void(id, opts, state), state}

      # overridable functions
      def init(opts), do: {:ok, opts}
      
      def authorize(amount, card, opts, state),
        do: :not_implemented

      def capture(id, amount, opts, state),
        do: :not_implemented
      
      def purchase(amount, card, opts, state),
        do: :not_implemented

      def refund(id, opts, state),
        do: :not_implemented

      def store(card, opts, state),
        do: :not_implemented

      def unstore(id, opts, state),
        do: :not_implemented

      def void(id, opts, state),
        do: :not_implemented

      defoverridable [
        init: 1,
        authorize: 4,
        capture: 4,
        purchase: 4,
        refund: 3,
        store: 3,
        unstore: 3,
        void: 3
      ]
    end
  end
end