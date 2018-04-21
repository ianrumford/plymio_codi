defmodule PlymioCodiDelegate1ModuleA do
  def fun1(x) do
    {x}
  end

  def fun2(x, y) do
    {x, y}
  end

  def fun3(x, y, z) do
    {x, y, z}
  end
end

defmodule PlymioCodiDelegate1ModuleB do
  alias PlymioCodiDelegate1ModuleA, as: RealMod
  require Plymio.Codi, as: PFC

  [
    delegate: [
      name: :fun1,
      to: RealMod,
      args: quote(do: x)
    ]
  ]
  |> PFC.reify_codi()

  :functions
  |> RealMod.__info__()
  |> Keyword.drop([:fun1])
  |> Enum.flat_map(fn {name, arity} ->
    [delegate: [name: name, args: arity, to: RealMod, doc: :delegate]]
  end)
  |> PFC.reify_codi()
end

defmodule PlymioCodiDelegate1Test do
  use PlymioCodiHelperTest
  alias PlymioCodiDelegate1ModuleA, as: RealMod
  alias PlymioCodiDelegate1ModuleB, as: TestMod

  test "codi: 100a" do
    [
      fun1: 42,
      fun2: [3, 7],
      fun3: [1, 3, 9]
    ]
    |> Enum.each(fn {fun, args} ->
      real_result = apply(RealMod, fun, args |> List.wrap())
      test_result = apply(TestMod, fun, args |> List.wrap())

      assert real_result == test_result

      assert test_result == args |> List.wrap() |> List.to_tuple()
    end)
  end
end
