use Mix.Config

config :cashier, :cashier,
  defaults: [
    gateway: :dummy,
    currency: "USD"
  ]
  
config :cashier, :dummy, []

config :cashier, :test, []