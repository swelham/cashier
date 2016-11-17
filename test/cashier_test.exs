defmodule CashierTest do
  use ExUnit.Case
  doctest Cashier

  setup_all do
    {:ok, pid} = Cashier.TestGateway.start_link
    {:ok, %{gateway: pid}}
  end

  test "purchase/0 should call into default gateway" do
    result = Cashier.purchase()

    assert result == {:ok, "from bogus"} 
  end

  test "purchase/1 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.purchase([gateway: gateway])

    assert result == {:ok, "from test_gateway"} 
  end
end
