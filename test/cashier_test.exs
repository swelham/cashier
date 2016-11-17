defmodule CashierTest do
  use ExUnit.Case
  doctest Cashier

  test "purchase/0 should call into gateway" do
    result = Cashier.purchase()

    assert result == {:ok, "from bogus"} 
  end
end
