defmodule Cashier.Gateways.Base do
  defmacro __using__(_opts) do
    quote do
      def start_link(state, {pid, data, opts}) do
        Task.start_link(fn ->
          # todo: error handling here needs some thought
          {:ok, state} = init(state)

          send(pid, {:ok, call(data, opts, state)})
        end)
      end

      def call({:authorize, amount, card}, opts, state) do
        authorize(amount, card, opts, state)
          |> handle_response
      end
      def call({:capture, id, amount}, opts, state) do
        capture(id, amount, opts, state)
          |> handle_response
      end
      def call({:purchase, amount, card}, opts, state) do
        purchase(amount, card, opts, state)
          |> handle_response
      end
      def call({:refund, id}, opts, state) do
        refund(id, opts, state)
          |> handle_response
      end
      def call({:store, card}, opts, state) do
        store(card, opts, state)
          |> handle_response
      end
      def call({:unstore, id}, opts, state) do
        unstore(id, opts, state)
          |> handle_response
      end
      def call({:void, id}, opts, state) do
        void(id, opts, state)
          |> handle_response
      end

      # todo: need to look into the error cases here and how to handle them
      def handle_response(response), do: response

      # def handle_response({:ok, _} = response),
      #   do: {:reply, response}
      # def handle_response({:ok, _, _} = response),
      #   do: {:reply, response}
      # def handle_response({:stop, reason}),
      #   do: {:stop, :normal, reason}
      # def handle_response(_, _),
      #   do: {:stop, :normal, {:error, :unknown_response}}

      # overridable functions
      def init(state), do: {:ok, state}

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