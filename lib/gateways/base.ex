defmodule Cashier.Gateways.Base do
  defmacro __using__(_opts) do
    quote do
      def start_link({pid, data, opts}) do
        Task.start_link(fn -> 
          send(pid, {:ok, call(data, opts)})
        end)
      end

      def call({:authorize, amount, card}, opts) do
        authorize(amount, card, opts)
          |> handle_response
      end
      def call({:capture, id, amount}, opts) do
        capture(id, amount, opts)
          |> handle_response
      end
      def call({:purchase, amount, card}, opts) do
        purchase(amount, card, opts)
          |> handle_response
      end
      def call({:refund, id}, opts) do
        refund(id, opts)
          |> handle_response
      end
      def call({:store, card}, opts) do
        store(card, opts)
          |> handle_response
      end
      def call({:unstore, id}, opts) do
        unstore(id, opts)
          |> handle_response
      end
      def call({:void, id}, opts) do
        void(id, opts)
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
      def authorize(amount, card, opts),
        do: :not_implemented

      def capture(id, amount, opts),
        do: :not_implemented
      
      def purchase(amount, card, opts),
        do: :not_implemented

      def refund(id, opts),
        do: :not_implemented

      def store(card, opts),
        do: :not_implemented

      def unstore(id, opts),
        do: :not_implemented

      def void(id, opts),
        do: :not_implemented

      defoverridable [
        authorize: 3,
        capture: 3,
        purchase: 3,
        refund: 2,
        store: 2,
        unstore: 2,
        void: 2
      ]
    end
  end
end