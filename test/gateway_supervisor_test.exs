defmodule Cashier.GatewaySupervisorTest do
  use ExUnit.Case

  test "supervisor should start children configured in application env" do
    [{gateway, _, _, _}] = Supervisor.which_children(Cashier.GatewaySupervisor)

    assert gateway == Cashier.Gateways.Dummy
  end
end
