defmodule Cashier.Gateways.Base do
  defmacro __using__(opts) do
    quote do
      def start_link,
        do: start_link([])

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: unquote(opts[:name]))
      end

      def handle_call({:authorize, amount, card, opts}, _from, state) do
        authorize(amount, card, opts, state)
          |> handle_response(state)
      end
      def handle_call({:capture, id, amount, opts}, _from, state) do
        capture(id, amount, opts, state)
          |> handle_response(state)
      end
      def handle_call({:purchase, amount, card, opts}, _from, state) do
        purchase(amount, card, opts, state)
          |> handle_response(state)
      end
      def handle_call({:refund, id, opts}, _from, state) do
        refund(id, opts, state)
          |> handle_response(state)
      end
      def handle_call({:store, card, opts}, _from, state) do
        store(card, opts, state)
          |> handle_response(state)
      end
      def handle_call({:unstore, id, opts}, _from, state) do
        unstore(id, opts, state)
          |> handle_response(state)
      end
      def handle_call({:void, id, opts}, _from, state) do
        void(id, opts, state)
          |> handle_response(state)
      end

      def handle_response({:ok, _} = response, state),
        do: {:reply, response, state}
      def handle_response({:ok, _, _} = response, state),
        do: {:reply, response, state}
      def handle_response({:error, _, _} = response, state),
        do: {:reply, response, state}
      def handle_response({:stop, reason}, state),
        do: {:stop, :normal, reason, state}
      def handle_response(_, _, state),
        do: {:stop, :normal, {:error, :unknown_response}, state}

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

      def terminate(reason, state),
        do: :not_implemented

      defoverridable [
        init: 1,
        authorize: 4,
        capture: 4,
        purchase: 4,
        refund: 3,
        store: 3,
        unstore: 3,
        void: 3,
        terminate: 2
      ]
    end
  end
end