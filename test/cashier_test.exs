defmodule CashierTest do
  use ExUnit.Case
  doctest Cashier

  setup do
    {:ok, pid} = Cashier.TestGateway.start_link
    {:ok, %{gateway: pid}}
  end

  test "authorize/0 should call into default gateway" do
    result = Cashier.authorize()

    assert result == {:ok, "authorize from dummy_gateway"}
  end

  test "authorize/1 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.authorize([gateway: gateway])

    assert result == {:ok, "authorize from test_gateway"}
  end

  test "capture/0 should call into default gateway" do
    result = Cashier.capture()

    assert result == {:ok, "capture from dummy_gateway"}
  end

  test "capture/1 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.capture([gateway: gateway])
    
    assert result == {:ok, "capture from test_gateway"}
  end

  test "purchase/0 should call into default gateway" do
    result = Cashier.purchase()

    assert result == {:ok, "purchase from dummy_gateway"} 
  end

  test "purchase/1 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.purchase([gateway: gateway])

    assert result == {:ok, "purchase from test_gateway"} 
  end

  test "refund/0 should call into default gateway" do
    result = Cashier.refund()

    assert result == {:ok, "refund from dummy_gateway"} 
  end

  test "refund/1 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.refund([gateway: gateway])

    assert result == {:ok, "refund from test_gateway"} 
  end

  test "void/0 should call into default gateway" do
    result = Cashier.void()

    assert result == {:ok, "void from dummy_gateway"} 
  end

  test "void/1 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.void([gateway: gateway])

    assert result == {:ok, "void from test_gateway"} 
  end
end
