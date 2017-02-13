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

      assert "/v1/oauth2/token" == conn.request_path
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

  test "all requests should return decoded error results", %{config: config, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      Plug.Conn.send_resp(conn, 400, Fixtures.error_response)
    end

    err_result = [
      {"billing_address", "state",        "billing_address.state error"},
      {"billing_address", "postal_code",  "billing_address.postal_code error"},
      {"billing_address", "country_code", "billing_address.country_code error"},
      {"billing_address", "city",         "billing_address.city error"},
      {"billing_address", "line2",        "billing_address.line2 error"},
      {"billing_address", "line1",        "billing_address.line1 error"},
      {"credit_card",     "holder",       "credit_card.last_name error"},
      {"credit_card",     "holder",       "credit_card.first_name error"},
      {"credit_card",     "cvv",          "credit_card.cvv2 error"},
      {"credit_card",     "expiry",       "credit_card.expire_year error"},
      {"credit_card",     "expiry",       "credit_card.expire_month error"},
      {"credit_card",     "brand",        "credit_card.type error"},
      {"credit_card",     "number",       "credit_card.number error"}
    ]

    opts = default_opts() ++ [billing_address: address()]

    assert {:error, :invalid, err_result} == Gateway.authorize(9.75, payment_card(), opts, config)
    assert {:error, :invalid, err_result} == Gateway.capture("1234", 9.75, opts, config)
    assert {:error, :invalid, err_result} == Gateway.purchase(9.75, payment_card(), opts, config)
    assert {:error, :invalid, err_result} == Gateway.refund("1234", opts, config)
    assert {:error, :invalid, err_result} == Gateway.store(payment_card(), opts, config)
    assert {:error, :invalid, err_result} == Gateway.unstore("CARD-123", [], config)
    assert {:error, :invalid, err_result} == Gateway.void("1234", [], config)
  end

  test "authorize/4 should successfully process a credit card authorization request", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"PAY-123\"}"

    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/payment" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.authorize_request

      Plug.Conn.send_resp(conn, 201, expected_response)
    end

    opts = default_opts() ++ [billing_address: address()]

    {:ok, id, {:paypal, response}} = Gateway.authorize(9.75, payment_card(), opts, config)

    assert id == "PAY-123"
    assert response == expected_response
  end

  test "authorize/4 should successfully process a stored credit card authorization request", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"PAY-123\"}"

    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/payment" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.authorize_stored_card_request

      Plug.Conn.send_resp(conn, 201, expected_response)
    end

    opts = default_opts() ++ [
      billing_address: address(),
      external_customer_id: "CUST-1"
    ]

    {:ok, id, {:paypal, response}} = Gateway.authorize(9.75, "CARD-123", opts, config)

    assert id == "PAY-123"
    assert response == expected_response
  end

  test "capture/4 should successfully process a capture request", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"5678\"}"

    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/authorization/1234/capture" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.capture_request

      Plug.Conn.send_resp(conn, 200, expected_response)
    end

    {:ok, id, {:paypal, response}} = Gateway.capture("1234", 9.75, default_opts(), config)

    assert id == "5678"
    assert response == expected_response
  end

  test "capture/4 should successfully process a final capture request ", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"5678\"}"
  
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/authorization/1234/capture" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.capture_final_request

      Plug.Conn.send_resp(conn, 200, expected_response)
    end

    opts = [final_capture: true] ++ default_opts()

    {:ok, id, {:paypal, response}} = Gateway.capture("1234", 9.75, opts, config)

    assert id == "5678"
    assert response == expected_response
  end

  test "purchase/4 should successfully process a credit card purchase request", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"PAY-123\"}"

    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/payment" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.purchase_request

      Plug.Conn.send_resp(conn, 201, expected_response)
    end

    opts = default_opts() ++ [billing_address: address()]

    {:ok, id, {:paypal, response}} = Gateway.purchase(9.75, payment_card(), opts, config)

    assert id == "PAY-123"
    assert response == expected_response
  end

  test "purchase/4 should successfully process a stored credit card purchase request", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"PAY-123\"}"

    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/payment" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.purchase_stored_card_request

      Plug.Conn.send_resp(conn, 201, expected_response)
    end

    opts = default_opts() ++ [
      billing_address: address(),
      external_customer_id: "CUST-1"
    ]

    {:ok, id, {:paypal, response}} = Gateway.purchase(9.75, "CARD-123", opts, config)

    assert id == "PAY-123"
    assert response == expected_response
  end

  test "refund/3 should successfully process a refund request", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"5678\"}"

    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/sale/1234/refund" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == "{}"

      Plug.Conn.send_resp(conn, 200, expected_response)
    end

    opts = default_opts()

    {:ok, id, {:paypal, response}} = Gateway.refund("1234", opts, config)

    assert id == "5678"
    assert response == expected_response
  end

  test "refund/3 should successfully process a partial refund request", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"5678\"}"

    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/sale/1234/refund" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.partial_refund_request

      Plug.Conn.send_resp(conn, 200, expected_response)
    end

    opts = [amount: 9.75] ++ default_opts()

    {:ok, id, {:paypal, response}} = Gateway.refund("1234", opts, config)

    assert id == "5678"
    assert response == expected_response
  end

  test "store/3 should successfully process a credit card store request", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"CARD-123\"}"

    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/vault/credit-cards" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == Fixtures.store_request

      Plug.Conn.send_resp(conn, 201, expected_response)
    end

    opts = default_opts() ++ [
      billing_address: address(),
      external_customer_id: "CUST-1"
    ]

    {:ok, id, {:paypal, response}} = Gateway.store(payment_card(), opts, config)

    assert id == "CARD-123"
    assert response == expected_response
  end

  test "unstore/3 should successfully process a credit card unstore request", %{config: config, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "DELETE" == conn.method
      assert "/v1/vault/credit-cards/CARD-123" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})

      Plug.Conn.send_resp(conn, 204, "")
    end

    {:ok, {:paypal, nil}} = Gateway.unstore("CARD-123", [], config)
  end

  test "void/3 should successfully process a void authorization request", %{config: config, bypass: bypass} do
    expected_response = "{\"id\":\"5678\"}"

    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "/v1/payments/authorization/1234/void" == conn.request_path
      assert has_header(conn, {"authorization", "bearer some.token"})
      assert has_header(conn, {"content-type", "application/json"})
      assert body == "{}"

      Plug.Conn.send_resp(conn, 200, expected_response)
    end

    {:ok, id, {:paypal, response}} = Gateway.void("1234", [], config)

    assert id == "5678"
    assert response == expected_response
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