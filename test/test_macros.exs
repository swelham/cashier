defmodule Cashier.TestMacros do
  defmacro has_header(conn, header) do
    quote do
      Enum.member?(unquote(conn).req_headers, unquote(header))
    end
  end
end