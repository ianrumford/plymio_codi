defmodule PlymioCodiPatternQueryDoctest1Test do
  use ExUnit.Case, async: false
  use PlymioCodiHelperTest
  import Plymio.Codi

  doctest Plymio.Codi.Pattern.Query
end
