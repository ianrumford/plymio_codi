ExUnit.start()

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

defmodule PlymioCodiHelperTest do
  require Plymio.Fontais.Option.Macro, as: PFOM
  use Plymio.Codi

  import Plymio.Fontais.Option,
    only: [
      opts_validate: 1,
      opts_get: 3
    ]

  [
    opts_get_fields: %{
      key: :fields,
      default: [
        x: 42,
        y: nil,
        z: @plymio_fontais_the_unset_value
      ]
    }
  ]
  |> PFOM.def_custom_opts_get()

  def codi_helper_struct_compile_module(snippets, opts \\ []) do
    with {:ok, opts} <- opts |> opts_validate,
         {:ok, fields} <- opts |> opts_get_fields,
         {:ok, {forms, _}} <- snippets |> CODI.produce_codi(),
         true <- true do
      form =
        quote do
          use Plymio.Codi

          @type error :: Plymio.Fontais.error()

          defstruct unquote(fields)

          unquote_splicing(forms)
        end

      module_name = "PlymioCodiStructTest#{:rand.uniform(99_999_999)}" |> String.to_atom()

      module_name
      |> Module.create(form, __ENV__)
      |> case do
        {:module, ^module_name, _, _} ->
          {:ok, {forms, module_name}}

        _ ->
          {:error, %RuntimeError{message: "module create failed"}}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defmacro __using__(_opts \\ []) do
    quote do
      use ExUnit.Case, async: true
      use Plymio.Codi
      import PlymioCodiHelperTest
      import Harnais.Helper, warn: false
    end
  end
end
