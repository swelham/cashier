defmodule CashierTest do
  use ExUnit.Case
  doctest Cashier

  setup do
    {:ok, pid} = Cashier.TestGateway.start_link
    {:ok, %{gateway: pid}}
  end

  @tag me: true
  test "authorize/2 should call into default gateway" do
    result = Cashier.authorize(0, nil)

    assert result == {:ok, "authorize_id", {:dummy, "raw_data"}}
  end

  test "authorize/3 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.authorize(0, nil, [gateway: gateway])

    assert result == {:ok, "authorize_id", {:test, "raw_data"}}
  end

  test "capture/2 should call into default gateway" do
    result = Cashier.capture(nil, 0)

    assert result == {:ok, "capture_id", {:dummy, "raw_data"}}
  end

  test "capture/3 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.capture(nil, 0, [gateway: gateway])
    
    assert result ==  {:ok, "capture_id", {:test, "raw_data"}}
  end

  test "purchase/2 should call into default gateway" do
    result = Cashier.purchase(0, nil)

    assert result == {:ok, "purchase_id", {:dummy, "raw_data"}}
  end

  test "purchase/3 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.purchase(0, nil, [gateway: gateway])

    assert result == {:ok, "purchase_id", {:test, "raw_data"}}
  end

  test "refund/1 should call into default gateway" do
    result = Cashier.refund(0)

    assert result == {:ok, "refund_id", {:dummy, "raw_data"}}
  end

  test "refund/2 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.refund(0, [gateway: gateway])

    assert result == {:ok, "refund_id", {:test, "raw_data"}}
  end

  test "store/1 should call into default gateway" do
    result = Cashier.store(nil)

    assert result == {:ok, "store_id", {:dummy, "raw_data"}}
  end

  test "store/2 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.store(nil, [gateway: gateway])

    assert result == {:ok, "store_id", {:test, "raw_data"}}
  end

  test "unstore/1 should call into default gateway" do
    result = Cashier.unstore(nil)

    assert result == {:ok, {:dummy, "raw_data"}}
  end

  test "unstore/2 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.unstore(nil, [gateway: gateway])

    assert result == {:ok, {:test, "raw_data"}}
  end

  test "void/1 should call into default gateway" do
    result = Cashier.void("")

    assert result == {:ok, "void_id", {:dummy, "raw_data"}}
  end

  test "void/2 should call into a specified gateway", %{gateway: gateway} do
    result = Cashier.void("", [gateway: gateway])

    assert result == {:ok, "void_id", {:test, "raw_data"}}
  end
end
