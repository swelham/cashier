defmodule Cashier.Gateways.PayPal do
  use Cashier.Gateways.Base, name: :paypal

  alias Cashier.HttpRequest
  alias Cashier.Address
  alias Cashier.PaymentCard

  def init(opts) do
    body = %{grant_type: "client_credentials"}
    api_keys = {opts[:client_id], opts[:client_secret]}
    
    request =
      HttpRequest.new(:post, resolve_url(opts, "/oauth2/token"))
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
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:stop, unexpected_status_error(status_code, "requesting the PayPal access_token")}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:stop, reason}
    end
  end

  def authorize(amount, card, opts, state) do
    req_data = %{}
      |> put_intent(:authorize)
      |> put_payer(card, opts)
      |> put_transactions(amount, opts)
    
    request("/v1/payments/payment", req_data, state)
  end

  def capture(id, amount, opts, state) do
    req_data = %{}
      |> put_capture_amount(amount, opts)
      |> put_final_capture(opts)

    request("/v1/payments/authorization/#{id}/capture", req_data, state)
  end

  def purchase(amount, card, opts, state) do
    req_data = %{}
      |> put_intent(:sale)
      |> put_payer(card, opts)
      |> put_transactions(amount, opts)
    
    request("/v1/payments/payment", req_data, state)
  end

  defp request(url, data, state) do
    HttpRequest.new(:post, resolve_url(state, url))
      |> HttpRequest.put_auth(:bearer, state[:access_token])
      |> HttpRequest.put_body(data, :json)
      |> HttpRequest.send
      |> respond
  end

  defp respond({:ok, %{status_code: status_code, body: body}}) when status_code in [200, 201],
    do: Poison.decode(body)

  defp respond({:ok, %{status_code: status_code, body: body}}),
    do: {:error, unexpected_status_error(status_code, body)}
  
  defp respond({:error, reason}),
    do: {:error, reason}

  defp resolve_url(config, path),
    do: "#{config[:url]}#{path}"

  defp put_access_token(token, opts),
    do: Keyword.put(opts, :access_token, token)

  # TODO: improve error reporting
  defp unexpected_status_error(status_code, action),
    do: "Unexpected status code (#{status_code}) returned #{action}"

  defp put_intent(map, :sale),
    do: Map.put(map, :intent, "sale")

  defp put_intent(map, :authorize),
    do: Map.put(map, :intent, "authorize")
    
  defp put_payer(map, card, opts) do
    payer = %{}
      |> Map.put(:payment_method, "credit_card")
      |> put_funding_instruments(card, opts)
    
    Map.put(map, :payer, payer)
  end
  
  defp put_funding_instruments(map, card, opts) do
    credit_card = put_credit_card(%{}, card, opts)
    
    Map.put(map, :funding_instruments, [credit_card])
  end
  
  defp put_credit_card(map, card = %PaymentCard{}, opts) do
    {expire_month, expire_year} = card.expiry
    {holder_first, holder_last} = card.holder
  
    credit_card = %{
      type: card.brand,
      number: card.number,
      expire_year: expire_year,
      expire_month: expire_month,
      cvv2: card.cvv,
      first_name: holder_first,
      last_name: holder_last
    }
    |> put_billing_address(opts[:billing_address])
      
    Map.put(map, :credit_card, credit_card)
  end
  
  defp put_billing_address(map, %Address{} = address) do
    address = %{
      line1: address.line1,
      line2: address.line2,
      city: address.city,
      country_code: address.country_code,
      state: address.state,
      postal_code: address.postal_code
    }

    Map.put(map, :billing_address, address)
  end
  
  defp put_transactions(map, amount, opts) do
    # TODO: add support for tax and shipping costs
    amount_map = %{
      total: amount,
      currency: opts[:currency],
      details: %{
        subtotal: amount,
        tax: 0,
        shipping: 0
      }
    }
    
    Map.put(map, :transactions, [%{amount: amount_map}])
  end

  defp put_capture_amount(map, amount, opts) do
    amount = %{
      currency: opts[:currency],
      total: amount
    }

    Map.put(map, :amount, amount)
  end

  defp put_final_capture(map, opts) do
    case opts[:final_capture] do
      true -> Map.put(map, :is_final_capture, true)
      _ -> map 
    end
  end
end