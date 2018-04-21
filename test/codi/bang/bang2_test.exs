defmodule PlymioCodiBang2ModuleA do
  require Plymio.Codi, as: PFC

  def fun1(x) do
    {:ok, {x}}
  end

  def fun2(x, y) do
    {:ok, {x, y}}
  end

  def fun3(x, y, z) do
    {:error, %ArgumentError{message: "fun3(#{inspect(x)},#{inspect(y)},#{inspect(z)})"}}
  end

  @quote_result quote(do: {:ok, any} | {:error, struct})

  @fun3_docstring "This is fun3 docstring"

  [
    fun1: [args: :x, type_args: 1, type_result: @quote_result],
    fun2: [args: [:x, :y], type_args: [:integer, :integer], type_result: @quote_result],
    fun3: [args: 3, doc: @fun3_docstring]
  ]
  |> Enum.flat_map(fn {name, opts} ->
    [bang: opts |> Keyword.put_new(:bang_name, name)]
  end)
  |> PFC.reify_codi()
end

defmodule PlymioCodiBang2Test do
  use PlymioCodiHelperTest
  alias PlymioCodiBang2ModuleA, as: RealMod

  test "bang: 100a" do
    [
      fun1: 42,
      fun2: [3, 7]
    ]
    |> Enum.each(fn {real_name, args} ->
      real_args = args |> List.wrap()
      bang_args = real_args

      real_result = apply(RealMod, real_name, real_args)

      assert real_result == {:ok, real_args |> List.to_tuple()}

      bang_name = "#{real_name}!" |> String.to_atom()

      bang_result = apply(RealMod, bang_name, bang_args)

      assert bang_result == bang_args |> List.to_tuple()
    end)
  end

  test "bang: 200a" do
    [
      fun3: [1, 3, 9],
      fun3: [5, 1, 99]
    ]
    |> Enum.each(fn {real_name, args} ->
      real_args = args |> List.wrap()
      bang_args = real_args

      real_result = apply(RealMod, real_name, real_args)

      assert {:error, error} = real_result

      assert error |> Exception.exception?()

      error_message =
        [
          real_name |> to_string,
          "(",
          real_args |> Enum.map(&to_string/1) |> Enum.intersperse(","),
          ")"
        ]
        |> Enum.join()

      assert error_message == error |> Exception.message()

      bang_name = "#{real_name}!" |> String.to_atom()

      assert_raise ArgumentError, fn ->
        apply(RealMod, bang_name, bang_args)
      end
    end)
  end
end
