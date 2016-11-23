# Cashier

[![Build Status](https://travis-ci.org/swelham/cashier.svg?branch=master)](https://travis-ci.org/swelham/cashier)

Cashier is an Elixir library that aims to be an easy to use payment gateway, whilst offering the fault tolerance and scalability benefits of being built on top of Erlang/OTP

# Project Status

This is a new project and currently working towards implementating it's first payment gateway (PayPal).
The long term goal is to offer support for a wide range of payment gateways whilst maintaining an
easy to use public API and configuration.

# Usage

*This will be updated on completion of the first payment gateway*

# Todo (short term)
 
* PayPal Gateway (REST API)
  - [x] Authorizations
  - [x] Captures
  - [x] Purchases
  - [x] Refunds
  - [x] Voids
* Configuration
  - [x] Default gateway
  - [x] Default currency
  - [x] HTTP request options (passed into HTTPoison)
  - [ ] Currecny based gateway routing
  - [x] Load known gateways where configuration has been set
* Gateway failover (pass the request to an alternative gateway on failure)
* Gateway pooling
* Documentation