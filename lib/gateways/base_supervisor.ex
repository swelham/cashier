defmodule Cashier.Gateways.BaseSupervisor do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      defmodule Supervisor do
        use ConsumerSupervisor

        def init(_args), do: {:producer_consumer, :no_state}

        def start_link(_opts) do
          children = [
            worker(unquote(opts[:module]), [gateway_config()], restart: :temporary)
          ]

          ConsumerSupervisor.start_link(
            children,
            strategy: :one_for_one,
            name: __MODULE__,
            subscribe_to: [{
              Cashier.Pipeline.GatewayRouter,
              max_demand: default_config()[:max_gateway_workers] || 50,
              selector: &dispatch_selector/1
            }]
          )
        end

        defp dispatch_selector({_, _, opts}),
          do: Keyword.get(opts, :gateway) == unquote(opts[:name])
        defp dispatch_selector(_), do: false

        defp gateway_config,
          do: Application.get_env(:cashier, unquote(opts[:name]), nil)

        defp default_config do
          case Application.get_env(:cashier, :cashier) do
            nil -> []
            config -> config[:defaults]
          end
        end
      end
    end
  end
end
