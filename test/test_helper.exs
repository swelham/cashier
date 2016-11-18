Code.require_file("stubs/test_gateway.exs", __DIR__)

ExUnit.start()
Application.ensure_all_started(:bypass)