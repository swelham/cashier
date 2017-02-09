use Mix.Config

config :cashier, :cashier,
  defaults: [
    gateway: :dummy,
    currency: "USD",
    max_gateway_workers: 10
  ]
  
config :cashier, :dummy, []