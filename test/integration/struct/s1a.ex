defmodule PlymioCodiStruct1ModuleA do
  require Plymio.Codi, as: CODI
  require Plymio.Fontais.Guard
  use Plymio.Fontais.Attribute

  @type error :: struct

  defstruct x: @plymio_fontais_the_unset_value,
            y: 42,
            z: nil

  [
    struct_get: [
      args: [:moda, :usethisdefault],
      spec_args: [:struct, :any],
      field: :x,
      name: :get_a,
      result: :result
    ],
    struct_get1: [args: :moda, spec_args: :struct, field: :x, name: :get_a1, result: :result],
    struct_get2: [
      args: [:moda, :usethisdefault],
      spec_args: [:struct, :any],
      field: :x,
      name: :get_a2,
      result: :result
    ],
    struct_get: [field: :y, name: :get_b, result: :atom_result],
    struct_get: [field: :z, name: :get_c, result: :binary_result],
    struct_fetch: [args: :moda, spec_args: :struct, field: :x, name: :fetch_a, result: :result],
    struct_fetch: [field: :y, name: :fetch_b, result: :integer_result],
    struct_fetch: [field: :z, name: :fetch_c, result: :map_result],
    struct_put: [
      args: [:moda, :save_this],
      spec_args: [:struct, :any],
      field: :x,
      name: :put_a,
      result: :struct_result
    ],
    struct_put: [field: :y, name: :put_b, result: :struct_result],
    struct_put: [field: :z, name: :put_c, result: :struct_result],
    struct_maybe_put: [
      args: [:moda, :keepthis],
      spec_args: [:struct, :any],
      field: :x,
      name: :maybe_put_a,
      result: :struct_result
    ],
    struct_maybe_put: [field: :y, name: :maybe_put_b, result: :struct_result],
    struct_maybe_put: [field: :z, name: :maybe_put_c, result: :struct_result],
    struct_set: [
      args: :moda,
      spec_args: :struct,
      field: [x: 1],
      name: :set_a,
      result: :struct_result
    ],
    struct_set: [field: [y: :due], name: :set_b, result: :struct_result],
    struct_set: [field: [z: "tre"], name: :set_c, result: :struct_result],
    struct_set: [
      args: :moda,
      spec_args: :struct,
      field: [x: 1, y: :due, z: "tre"],
      name: :set_abc,
      result: :struct_result
    ],
    struct_set: [
      args: :moda,
      spec_args: :struct,
      field: :x,
      name: :reset_a,
      result: :struct_result,
      doc: "Unset `x` field"
    ],
    struct_has?: [
      args: :moda,
      spec_args: :struct,
      field: :x,
      name: :has_a?,
      result: :struct_result
    ],
    struct_has?: [field: :y, name: :has_b?, result: :struct_result],
    struct_has?: [field: :z, name: :has_c?, result: :struct_result],

    # update needs a vekil, state_base_package, etc

    struct_export: [args: :moda, spec_args: :struct, field: :x, name: :export_x, result: true],
    struct_export: [
      args: :moda,
      spec_args: :struct,
      field: [:x, :y],
      name: :export_xy,
      result: true
    ],
    struct_export: [field: [:z, :y, :x], name: :export_zyx, result: :opts_result],
    struct_export: [
      field: [:z, {:y, :y_export}, {:x, :x_export}],
      name: :export_zyx_d1,
      result: true
    ]
  ]
  |> CODI.reify_codi()
end
