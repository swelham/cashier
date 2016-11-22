defmodule Cashier.Gateways.PayPalTest do
  use ExUnit.Case, async: true

  import Cashier.TestMacros

  alias Bypass
  alias Cashier.Gateways.PayPal, as: Gateway
  alias Cashier.PayPalFixtures, as: Fixtures
  alias Cashier.Address
  alias Cashier.PaymentCard

  setup do
    bypass = Bypass.open

    config = [
      url: "http://localhost:#{bypass.port}",
      access_token: "some.token",
      client_id: "client_id",
      client_secret: "client_secret"
    ]

    {:ok, config: config, bypass: bypass}
  end

  test "init/1 should put the PayPal access_token into state", %{config: config, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "/oauth2/token" == conn.request_path
      assert "POST" == conn.method
      assert has_header(conn, {"authorization", "Basic Y2xpZW50X2lkOmNsaWVudF9zZWNyZXQ="})
      assert has_header(conn, {"content-type", "application/x-www-form-urlencoded"})
      assert body == "grant_type=client_credentials"
      
      Plug.Conn.send_resp(conn, 200, "{\"access_token\": \"some_token\"}")
    end

    config = Keyword.delete(config, :access_token)
    {:ok, result} = Gateway.init(config)

    assert result[:access_token] == "some_token"
  end

  test "init/1 should stop the process when an unexpected status code is returned", %{config: config, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      Plug.Conn.send_resp(conn, 201, "")
    end

    config = Keyword.delete(config, :access_token)
    {:stop, result} = Gateway.init(config)

    assert result == "Unexpected status code (201) returned requesting the PayPal access_token"
  end

  test "authorize/4 should successfully process a credit card authorization request", %{config: config, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/payment" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.authorize_request

      Plug.Conn.send_resp(conn, 201, "{\"id\":\"PAY-123\"}")
    end

    opts = default_opts ++ [billing_address: address]

    {:ok, result} = Gateway.authorize(9.75, payment_card, opts, config)

    assert result["id"] == "PAY-123"
  end

  test "capture/4 should successfully process a capture request", %{config: config, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/authorization/1234/capture" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.capture_request

      Plug.Conn.send_resp(conn, 200, "{\"id\":\"5678\"}")
    end

    {:ok, result} = Gateway.capture("1234", 9.75, default_opts, config)

    assert result["id"] == "5678"
  end

  test "capture/4 should successfully process a final capture request ", %{config: config, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/authorization/1234/capture" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.capture_final_request

      Plug.Conn.send_resp(conn, 200, "{\"id\":\"5678\"}")
    end

    opts = [final_capture: true] ++ default_opts

    {:ok, result} = Gateway.capture("1234", 9.75, opts, config)

    assert result["id"] == "5678"
  end

  test "purchase/4 should successfully process a credit card purchase request", %{config: config, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/payment" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.purchase_request

      Plug.Conn.send_resp(conn, 201, "{\"id\":\"PAY-123\"}")
    end

    opts = default_opts ++ [billing_address: address]

    {:ok, result} = Gateway.purchase(9.75, payment_card, opts, config)

    assert result["id"] == "PAY-123"
  end

  defp default_opts do
    [
      currency: "USD"
    ]
  end

  defp payment_card do
    %PaymentCard{
      holder: {"John", "Smith"},
      brand: "visa",
      number: "1234567890123456",
      expiry: {11, 2020},
      cvv: "123"
    }
  end

  defp address do
    %Address{
      line1: "123",
      line2: "Main",
      city: "New York",
      state: "New York",
      country_code: "NY",
      postal_code: "10004"
    }
  end
end