# Cashier

[![Join the chat at https://gitter.im/swelham/cashier](https://badges.gitter.im/swelham/cashier.svg)](https://gitter.im/swelham/cashier?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Build Status](https://travis-ci.org/swelham/cashier.svg?branch=master)](https://travis-ci.org/swelham/cashier) [![Hex Version](https://img.shields.io/hexpm/v/cashier.svg)](https://hex.pm/packages/cashier)

Cashier is an Elixir library that aims to be an easy to use payment gateway, whilst offering the fault tolerance and scalability benefits of being built on top of Erlang/OTP

# Project Status

This is a new project and currently working towards implementating it's first payment gateway (PayPal).
The long term goal is to offer support for a wide range of payment gateways whilst maintaining an
easy to use public API and configuration.

# Usage

The following are basic usage examples on how to use cashier in it's current state. This library is being activily developed and is likely to 
change as we move towards the first release.

### Setup

Add cashier as a dependency
```elixir
defp deps do
  {:cashier, "~> 0.2.0"}
end
```

Make sure the cashier application gets started
```elixir
def application do
  [applications: [:cashier]]
end
```

### Config options
```elixir
use Mix.Config

# cashier options
config :cashier, :cashier,
  defaults: [
    currency: "USD",
    gateway: :paypal,
    timeout: 20_000 # this option is the OTP timeout setting
  ],
  # this option is passed directly into HTTPoison and can contain any
  # of the valid options listed here - https://hexdocs.pm/httpoison/HTTPoison.html#request/5
  http: [
    recv_timeout: 20_000
  ]

# PayPal specific config
config :cashier, :paypal,
  # Please note the PayPal gateway currently only supports the /v1 endpoint
  # and this is automattically added for you
  url: "https://api.sandbox.paypal.com",
  client_id: "<paypal_client_id>",
  client_secret: "<paypal_client_secret>"
```

### Cashier request examples

```elixir
alias Cashier.Address
alias Cashier.PaymentCard

address = %Address{
    line1: "123",
    line2: "Main",
    city: "New York",
    state: "New York",
    country_code: "US",
    postal_code: "10004"
}

card = %PaymentCard{
    holder: {"John", "Smith"},
    brand: "visa",
    number: "4032030901103714",
    expiry: {11, 2021},
    cvv: "123"
}

# Note: The result return type for each request is currently the decoded
#       data returned from the payment provider, this will change in the future.

# Purchase request
# the card parameter can be either a %PaymentCard or stored card id 
case Cashier.purchase(9.99, card, [billing_address: address]) do
    {:ok, result}     -> IO.inspect result
    {:error, reason}  -> IO.inspect reason
end

# Authorize request
# the card parameter can be either a %PaymentCard or stored card id 
case Cashier.authorize(9.99, card, [billing_address: address]) do
    {:ok, result}     -> IO.inspect result
    {:error, reason}  -> IO.inspect reason
end

# Capture request
case Cashier.capture("<capture_id>", 19.45, [final_capture: true]) do
    {:ok, result}     -> IO.inspect result
    {:error, reason}  -> IO.inspect reason
end

#Void request
case Cashier.void("<void_id>") do
    {:ok, result}     -> IO.inspect result
    {:error, reason}  -> IO.inspect reason
end

#Refund request
case Cashier.refund("<refund_id>", [amount: 9.99]) do
    {:ok, result}     -> IO.inspect result
    {:error, reason}  -> IO.inspect reason
end

#Store request
case Cashier.store(card, [billing_address: address]) do
    {:ok, result}     -> IO.inspect result
    {:error, reason}  -> IO.inspect reason
end

#Unstore request
case Cashier.unstore("<card_id>") do
    :ok               -> IO.puts "card unstored"
    {:error, reason}  -> IO.inspect reason
end
```

# Todo

All current todo items are listed on the [issues page](https://github.com/swelham/cashier/issues).

Please add any issues, suggestions or feature requests to this page.
