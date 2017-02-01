defmodule Cashier.Gateways.BaseSupervisor do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts]  do
      defmodule Supervisor do
        use ConsumerSupervisor

        def init(_args), do: {:producer_consumer, :no_state}

        def start_link(_opts) do
          children = [
            worker(unquote(opts[:module]), [], restart: :temporary)
          ]

          ConsumerSupervisor.start_link(
            children,
            strategy: :one_for_one,
            name: __MODULE__,
            subscribe_to: [{
              Cashier.Pipeline.GatewayRouter,
              max_demand: 50, # todo: max_demand needs to be a config option
              selector: &dispatch_selector/1
            }],
          )
        end

        defp dispatch_selector({_, _, opts}),
          do: Keyword.get(opts, :gateway) == unquote(opts[:name])
        defp dispatch_selector(_), do: false
      end
    end
  end
end