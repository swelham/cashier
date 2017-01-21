defmodule Cashier.PayPalFixtures do

  def authorize_request do
    Poison.encode! %{
      intent: "authorize",
      payer: %{
        payment_method: "credit_card",
        funding_instruments: funding_instruments
      },
      transactions: transactions
    }
  end

  def capture_request do
    Poison.encode! %{
      amount: %{
        currency: "USD",
        total: 9.75
      }
    }
  end

  def capture_final_request do
    Poison.encode! %{
      amount: %{
        currency: "USD",
        total: 9.75
      },
      is_final_capture: true
    }
  end
  
  def partial_refund_request do
    Poison.encode! %{
      amount: %{
        currency: "USD",
        total: 9.75
      }
    }
  end

  def purchase_request do
    Poison.encode! %{
      intent: "sale",
      payer: %{
        payment_method: "credit_card",
        funding_instruments: funding_instruments
      },
      transactions: transactions
    }
  end

  def store_request do
    Poison.encode! credit_card
  end

  def transactions do
    [
      %{
        amount: %{
          total: 9.75,
          currency: "USD",
          details: %{
            shipping: 0,
            subtotal: 9.75,
            tax: 0
          }
        }  
      }
    ]
  end

  def funding_instruments do
    [
      %{
        credit_card: credit_card
      }
    ]
  end

  def credit_card do
    %{
      cvv2: "123",
      expire_month: 11,
      expire_year: 2020,
      first_name: "John",
      last_name: "Smith",
      number: "1234567890123456",
      type: "visa",
      billing_address: %{
        city: "New York",
        country_code: "NY",
        line1: "123",
        line2: "Main",
        postal_code: "10004",
        state: "New York"
      }
    }
  end
end