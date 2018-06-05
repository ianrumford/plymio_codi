ExUnit.start()

defmodule PlymioCodiHelperTest do
  defmacro __using__(_opts \\ []) do
    quote do
      use ExUnit.Case, async: false
      import Harnais.Helper
    end
  end
end
