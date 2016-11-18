defmodule Cashier.Gateways.PayPalTest do
  use ExUnit.Case, async: true

  alias Bypass
  alias Cashier.Gateways.PayPal, as: Gateway

  setup do
    bypass = Bypass.open

    opts = %{
      config: %{
        url: "http://localhost:#{bypass.port}",
        client_id: "client_id",
        client_secret: "client_secret"
        }
    }

    {:ok, opts: opts, bypass: bypass}
  end

  test "init/1 should put the PayPal access_token into opts", %{opts: opts, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "/oauth2/token" == conn.request_path
      assert "POST" == conn.method
      assert Enum.member?(conn.req_headers, {"authorization", "Basic Y2xpZW50X2lkOmNsaWVudF9zZWNyZXQ="})
      assert Enum.member?(conn.req_headers, {"content-type", "application/x-www-form-urlencoded"})
      assert body == "grant_type=client_credentials"
      
      Plug.Conn.send_resp(conn, 200, "{\"access_token\": \"some_token\"}")
    end

    {:ok, result} = Gateway.init(opts)

    assert result.access_token == "some_token"
  end

  test "init/1 should stop the process when an unexpected status code is returned", %{opts: opts, bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      Plug.Conn.send_resp(conn, 201, "")
    end

    {:stop, result} = Gateway.init(opts)

    assert result == "Unexpected status code (201) returned requesting the PayPal access_token"
  end
end