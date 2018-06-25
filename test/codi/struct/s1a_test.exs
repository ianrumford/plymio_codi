defmodule PlymioCodiStruct1ModuleATest do
  use PlymioCodiHelperTest
  alias PlymioCodiStruct1ModuleA, as: ModA
  use Plymio.Fontais.Attribute

  import Plymio.Fontais.Guard

  test "fva: ModA 100a" do
    fva =
      :functions
      |> ModA.__info__()
      |> Enum.sort()

    assert fva == [
             __struct__: 0,
             __struct__: 1,
             export_x: 1,
             export_xy: 1,
             export_zyx: 1,
             export_zyx_d1: 1,
             fetch_a: 1,
             fetch_b: 1,
             fetch_c: 1,
             get_a: 1,
             get_a: 2,
             get_a1: 1,
             get_a2: 2,
             get_b: 1,
             get_b: 2,
             get_c: 1,
             get_c: 2,
             has_a?: 1,
             has_b?: 1,
             has_c?: 1,
             maybe_put_a: 2,
             maybe_put_b: 2,
             maybe_put_c: 2,
             put_a: 2,
             put_b: 2,
             put_c: 2,
             reset_a: 1,
             set_a: 1,
             set_abc: 1,
             set_b: 1,
             set_c: 1
           ]
  end

  test "struct_new: 100a" do
    s = %ModA{}

    assert value = s |> Map.get(:x)
    assert is_value_unset(value)

    assert 42 = s |> Map.get(:y)

    assert is_nil(s |> Map.get(:z))
  end

  test "struct_get: 100a" do
    s = %ModA{}

    assert {:ok, value} = s |> ModA.get_a()
    assert is_value_unset(value)

    assert {:ok, 42} = s |> ModA.get_b()

    assert {:ok, nil} = s |> ModA.get_c()
  end

  test "struct_get: 200a" do
    s = %ModA{}

    assert {:ok, 99} = s |> ModA.get_a(99)

    assert {:ok, 42} = s |> ModA.get_b(123)

    assert {:ok, nil} = s |> ModA.get_c(456)
  end

  test "struct_fetch: 100a" do
    s = %ModA{}

    assert {:error, error} = s |> ModA.fetch_a()
    assert error |> Exception.message() |> String.starts_with?("struct field x unset")

    assert {:ok, 42} = s |> ModA.fetch_b()

    assert {:ok, nil} = s |> ModA.fetch_c()
  end

  test "struct_fetch: 200a" do
    s = %ModA{x: 99}

    assert {:ok, 99} = s |> ModA.fetch_a()

    assert {:ok, 42} = s |> ModA.fetch_b()

    assert {:ok, nil} = s |> ModA.fetch_c()
  end

  test "struct_put: 100a" do
    s = %ModA{}

    assert {:ok, %ModA{} = s} = s |> ModA.put_a(42)
    assert {:ok, 42} = s |> ModA.fetch_a()

    assert {:ok, %ModA{} = s} = s |> ModA.put_b(:due)
    assert {:ok, :due} = s |> ModA.fetch_b()

    assert {:ok, %ModA{} = s} = s |> ModA.put_c("tre")
    assert {:ok, "tre"} = s |> ModA.fetch_c()
  end

  test "struct_maybe_put: 100a" do
    s = %ModA{}

    # x field is unset by default
    assert {:ok, %ModA{} = s} = s |> ModA.maybe_put_a(42)
    assert {:ok, 42} = s |> ModA.fetch_a()

    # y field is set by default => no change
    assert {:ok, %ModA{} = s} = s |> ModA.maybe_put_b(:due)
    assert {:ok, 42} = s |> ModA.fetch_b()

    # z field is set and nil by default => no change
    assert {:ok, %ModA{} = s} = s |> ModA.maybe_put_c("tre")
    assert {:ok, nil} = s |> ModA.fetch_c()
  end

  test "struct_maybe_put: 200a" do
    s = %ModA{}

    assert {:ok, %ModA{} = s} = s |> ModA.maybe_put_a(@plymio_fontais_the_unset_value)
    assert {:error, error} = s |> ModA.fetch_a()
    assert error |> Exception.message() |> String.starts_with?("struct field x unset")

    assert {:ok, %ModA{} = s} = s |> ModA.maybe_put_b(@plymio_fontais_the_unset_value)
    assert {:ok, 42} = s |> ModA.fetch_b()

    assert {:ok, %ModA{} = s} = s |> ModA.maybe_put_c(@plymio_fontais_the_unset_value)
    assert {:ok, nil} = s |> ModA.fetch_c()
  end

  test "struct_set: 100a" do
    s = %ModA{}

    assert {:ok, %ModA{} = s} = s |> ModA.set_a()
    assert {:ok, 1} = s |> ModA.fetch_a()

    assert {:ok, %ModA{} = s} = s |> ModA.set_b()
    assert {:ok, :due} = s |> ModA.fetch_b()

    assert {:ok, %ModA{} = s} = s |> ModA.set_c()
    assert {:ok, "tre"} = s |> ModA.fetch_c()
  end

  test "struct_has?: 100a" do
    s = %ModA{}

    refute s |> ModA.has_a?()
    assert {:ok, %ModA{} = s} = s |> ModA.put_a(42)
    assert {:ok, 42} = s |> ModA.fetch_a()
    assert s |> ModA.has_a?()

    assert s |> ModA.has_b?()
    assert {:ok, %ModA{} = s} = s |> ModA.put_b(@plymio_fontais_the_unset_value)
    refute s |> ModA.has_b?()

    assert s |> ModA.has_c?()
    assert {:ok, %ModA{} = s} = s |> ModA.put_c(@plymio_fontais_the_unset_value)
    refute s |> ModA.has_c?()
  end

  test "struct_export: 100a" do
    s = %ModA{}

    assert {:ok, []} = s |> ModA.export_x()
    assert {:ok, %ModA{} = s} = s |> ModA.put_a(:one)
    assert {:ok, [x: :one]} = s |> ModA.export_x()

    assert {:ok, [x: :one, y: 42]} = s |> ModA.export_xy()

    assert {:ok, [z: nil, y: 42, x: :one]} = s |> ModA.export_zyx()
  end

  test "struct_export: 200a" do
    s = %ModA{}

    assert {:ok, [z: nil, y: 42, x: :x_export]} = s |> ModA.export_zyx_d1()

    assert {:ok, %ModA{} = s} = s |> ModA.put_b(@plymio_fontais_the_unset_value)

    assert {:ok, [z: nil, y: :y_export, x: :x_export]} = s |> ModA.export_zyx_d1()

    assert {:ok, %ModA{} = s} = s |> ModA.put_c(@plymio_fontais_the_unset_value)

    # opts is sparse: no unset values
    assert {:ok, [y: :y_export, x: :x_export]} = s |> ModA.export_zyx_d1()
  end
end
