defmodule Cashier.Gateways.PayPal do
  use Cashier.Gateways.Base, name: :paypal

  alias Cashier.HttpRequest

  def init(opts) do
    config = opts.config
    body = %{grant_type: "client_credentials"}
    api_keys = {config[:client_id], config[:client_secret]}
    
    request =
      HttpRequest.new(:post, url(opts, "/oauth2/token"))
      |> HttpRequest.put_body(body, :url_encoded)
      |> HttpRequest.put_auth(:basic, api_keys)

    case HttpRequest.send(request) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        opts =
          body
          |> Poison.decode!
          |> Map.get("access_token")
          |> put_access_token(opts)
        
        {:ok, opts}
      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:stop, "Unexpected status code (#{code}) returned requesting the PayPal access_token"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:stop, reason}
    end
  end

  def purchase(state) do
    state
  end

  defp url(%{config: config}, path),
    do: "#{config[:url]}#{path}"

  defp put_access_token(token, opts),
    do: Map.put(opts, :access_token, token)
end