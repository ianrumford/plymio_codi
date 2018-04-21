defmodule ModuleA do
  def fun_one(x) do
    {x}
  end

  def fun_due(x, y) do
    {x, y}
  end

  def fun_tre(x, y, z) do
    {x, y, z}
  end
end

defmodule PlymioCodiDoctest1Test do
  use ExUnit.Case, async: false
  use PlymioCodiHelperTest
  import Plymio.Codi

  doctest Plymio.Codi
end
