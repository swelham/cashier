Code.require_file("test_macros.exs", __DIR__)
Code.require_file("fixtures/paypal_fixtures.exs", __DIR__)
Code.require_file("stubs/test_gateway.exs", __DIR__)

ExUnit.start()
Application.ensure_all_started(:bypass)