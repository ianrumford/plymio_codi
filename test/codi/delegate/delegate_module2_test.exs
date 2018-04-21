defmodule PlymioCodiDelegateModule2ModuleA do
  def fun1(x) do
    {x}
  end

  def fun2(x, y) do
    {x, y}
  end

  def fun3(x, y, z) do
    {x, y, z}
  end

  def fun4(x, y, z, opts \\ []) do
    {x, y, z, opts}
  end
end

defmodule PlymioCodiDelegateModule2ModuleB do
  alias PlymioCodiDelegateModule2ModuleA, as: RealMod
  require Plymio.Codi, as: PFC
  use Plymio.Codi.Attribute

  [
    pattern: [
      pattern: :delegate_module,
      module: PlymioCodiDelegateModule2ModuleA,
      take: [:fun1, :fun2, :fun4],
      drop: :fun2
    ]
  ]
  |> PFC.reify_codi()
end

defmodule PlymioCodiDelegate3Test do
  use PlymioCodiHelperTest
  alias PlymioCodiDelegateModule2ModuleA, as: RealMod
  alias PlymioCodiDelegateModule2ModuleB, as: TestMod

  test "codi: fva 100a" do
    fva =
      :functions
      |> TestMod.__info__()

    assert [
             fun1: 1,
             fun4: 3,
             fun4: 4
           ] == fva
  end

  test "codi: funs 100a" do
    [
      fun1: 42,
      fun1: 3
    ]
    |> Enum.each(fn {fun, args} ->
      real_result = apply(RealMod, fun, args |> List.wrap())
      test_result = apply(TestMod, fun, args |> List.wrap())

      assert real_result == test_result

      assert test_result == args |> List.wrap() |> List.to_tuple()
    end)
  end
end
