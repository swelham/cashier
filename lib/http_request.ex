defmodule Cashier.HttpRequest do
  defstruct [:method, :url, :headers, :body, :auth_mode, :credentials, :opts]
  
  alias Poison
  alias Cashier.HttpRequest
  
  def new(method, url) do
    %HttpRequest{
      method: method,
      url: url,
      headers: [],
      opts: []
    }
  end
  
  def put_body(request, params, encoding) do
    con_type = content_type(encoding)
    
    request
      |> put_encoded_body(encoding, params)
      |> put_header(con_type)
  end
  
  def put_auth(request, :basic, credentials) do
    request
      |> Map.put(:auth_mode, :basic)
      |> Map.put(:credentials, [hackney: [basic_auth: credentials]])
  end
  
  def put_auth(request, :bearer, token) do
    request
      |> Map.put(:auth_mode, :bearer)
      |> put_header({"authorization", "bearer #{token}"})
  end
  
  def send(request = %{method: :get}) do
    opts = prepare_request_opts(request)

    HTTPoison.get(
      request.url,
      request.headers,
      opts)
  end

  def send(request = %{auth_mode: :basic}) do
    opts = prepare_request_opts(request)

    HTTPoison.request(
      request.method,
      request.url,
      request.body,
      request.headers,
      opts)
  end
  
  def send(request) do
    opts = prepare_request_opts(request)

    HTTPoison.request(
      request.method,
      request.url,
      request.body,
      request.headers,
      opts)
  end
  
  defp put_header(request, header),
    do: Map.put(request, :headers, [header | request.headers])
  
  defp content_type(:url_encoded),
    do: {"content-type", "application/x-www-form-urlencoded"}
    
  defp content_type(:json),
    do: {"content-type", "application/json"}
    
  defp put_encoded_body(map, encoding, data),
    do: Map.put(map, :body, encode_body(encoding, data))

  defp encode_body(:url_encoded, params) do
    params
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> URI.encode_query
  end

  defp encode_body(:json, params),
    do: Poison.encode!(params)
  
  defp encode_body(_, params),
    do: params

  defp prepare_request_opts(request) do
    config = Application.get_env(:cashier, :cashier)

    request.opts
      |> put_http_config(config)
      |> put_credentials(request)
  end

  defp put_http_config(opts, config) do
    case config[:http] do
      nil -> opts
      config -> config ++ opts
    end
  end

  defp put_credentials(opts, %{auth_mode: :basic, credentials: credentials}),
    do: credentials ++ opts
  defp put_credentials(opts, _),
    do: opts
end