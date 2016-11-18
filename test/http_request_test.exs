defmodule Cashier.HttpRequestTest do
  use ExUnit.Case
  
  alias Cashier.HttpRequest
  
  setup do
    bypass = Bypass.open

    {:ok, bypass: bypass}
  end

  test "new/2 should return a new HttpRequest struct" do
    request = HttpRequest.new(:post, "http://example.com")
    
    assert request == %HttpRequest {
      method: :post,
      url: "http://example.com",
      headers: []
    }
  end
  
  test "put_body/3 should set the body field using json encoding" do
    request =
      HttpRequest.new(:post, "")
      |> HttpRequest.put_body(%{test: "value"}, :json)
      
    assert request.headers == [{"content-type", "application/json"}]
    assert request.body == "{\"test\":\"value\"}"
  end
  
  test "put_body/3 should set the body field using url encoding encoding" do
    request =
      HttpRequest.new(:post, "")
      |> HttpRequest.put_body(%{test: "value"}, :url_encoded)
      
    assert request.headers == [{"content-type", "application/x-www-form-urlencoded"}]
    assert request.body == "test=value"
  end
  
  test "put_auth/3 should set auth to basic" do
    request =
      HttpRequest.new(:post, "")
      |> HttpRequest.put_auth(:basic, {"user", "pass"})
    
    assert request.auth_mode == :basic
    assert request.credentials == [hackney: [basic_auth: {"user", "pass"}]]
  end
  
  test "put_auth/3 should set auth to bearer" do
    request =
      HttpRequest.new(:post, "")
      |> HttpRequest.put_auth(:bearer, "token")
    
    assert request.auth_mode == :bearer
    assert request.headers == [{"authorization", "bearer token"}]
  end

  test "send/1 should send GET request with basic auth", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "GET" == conn.method 
      assert "localhost" == conn.host 
      assert bypass.port == conn.port
      assert Enum.member?(conn.req_headers, {"authorization", "Basic dXNlcjpwYXNz"})

      Plug.Conn.send_resp(conn, 200, "")
    end
    
    {:ok, %HTTPoison.Response{} = result} =
      HttpRequest.new(:get, "http://localhost:#{bypass.port}")
      |> HttpRequest.put_auth(:basic, {"user", "pass"})
      |> HttpRequest.send

    assert result.status_code == 200
  end

  test "send/1 should send GET request with bearer auth", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert "GET" == conn.method
      assert "localhost" == conn.host
      assert bypass.port == conn.port
      assert Enum.member?(conn.req_headers, {"authorization", "bearer some_token"})

      Plug.Conn.send_resp(conn, 200, "")
    end
    
    {:ok, %HTTPoison.Response{} = result} =
      HttpRequest.new(:get, "http://localhost:#{bypass.port}")
      |> HttpRequest.put_auth(:bearer, "some_token")
      |> HttpRequest.send

    assert result.status_code == 200
  end

  test "send/1 should send POST request with url encoded data", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "localhost" == conn.host
      assert bypass.port == conn.port
      assert Enum.member?(conn.req_headers, {"content-type", "application/x-www-form-urlencoded"})
      assert body == "abc=123"

      Plug.Conn.send_resp(conn, 200, "")
    end
    
    {:ok, %HTTPoison.Response{} = result} =
      HttpRequest.new(:post, "http://localhost:#{bypass.port}")
      |> HttpRequest.put_body(%{abc: 123}, :url_encoded)
      |> HttpRequest.send

    assert result.status_code == 200
  end

  test "send/1 should send POST request with json data", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert "POST" == conn.method
      assert "localhost" == conn.host
      assert bypass.port == conn.port
      assert Enum.member?(conn.req_headers, {"content-type", "application/json"})
      assert body == "{\"abc\":123}"

      Plug.Conn.send_resp(conn, 200, "")
    end
    
    {:ok, %HTTPoison.Response{} = result} =
      HttpRequest.new(:post, "http://localhost:#{bypass.port}")
      |> HttpRequest.put_body(%{abc: 123}, :json)
      |> HttpRequest.send

    assert result.status_code == 200
  end
end