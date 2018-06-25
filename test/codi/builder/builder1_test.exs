defmodule PlymioCodiUtilityBuilderBuilder1TestTest do
  use PlymioCodiHelperTest
  use Plymio.Codi
  alias Plymio.Codi.Utility.Builder, as: BUILDER

  import Plymio.Codi.CPO

  test "builder: struct getset 100a" do
    struct_getset_namer = fn name, verb ->
      {:ok, ["correr_", name, "_", verb] |> Enum.join() |> String.to_atom()}
    end

    struct_pattern_namer = fn _name, verb ->
      {:ok, ["struct_", verb] |> Enum.join() |> String.to_atom()}
    end

    struct_pattern_builder = fn cpo, name, verb ->
      with {:ok, pattern} <- struct_pattern_namer.(name, verb),
           {:ok, getset_name} <- struct_getset_namer.(name, verb),
           {:ok, cpo} <- cpo |> cpo_put_pattern(pattern),
           {:ok, cpo} <- cpo |> cpo_put_fun_name(getset_name),
           {:ok, cpo} <- cpo |> cpo_put_fun_key(name),
           true <- true do
        {:ok, cpo}
      else
        {:error, %{__exception__: true}} = result -> result
      end
    end

    struct_getset_default = %{patterns: [:get, :get, :put, :put], cpo: [fun_doc: false]}

    opts = []

    with {:ok, opts} <- opts |> BUILDER.builder_put_getset_default(struct_getset_default),
         {:ok, opts} <- opts |> BUILDER.builder_put_pattern_builder(struct_pattern_builder),
         true <- true do
      getset_specs = [
        test_type: %{funs: [:fetch, :maybe_put, :put]},
        test_flag: nil,
        test_mapper: %{funs: [:fetch]},
        test_transform: %{funs: [:fetch]},
        test_runner: %{funs: [:fetch, :maybe_put]},
        test_module: %{funs: [:get]},
        test_namer: %{funs: [:get]},
        test_value: %{funs: [:get, :fetch, :put, :delete]},
        test_specs: %{funs: [:get, :fetch, :put, :delete]},
        test_provas: %{funs: [:get, :fetch, :put, :delete]},
        compare_module: %{funs: [:get]}
      ]

      getset_fields =
        getset_specs
        |> Enum.map(fn {k, _} -> {k, @plymio_fontais_the_unset_value} end)

      compile_opts = [fields: getset_fields]

      getset_specs
      |> BUILDER.create_struct_getset_patterns(opts)
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, patterns} ->
          # patterns_opts = patterns

          with {:ok, {forms, test_mod}} <-
                 patterns |> codi_helper_struct_compile_module(compile_opts),
               {:ok, texts} <- forms |> harnais_helper_format_forms,
               true <- true do
            {:ok, {texts, forms, test_mod}}
          else
            {:error, %{__exception__: true}} = result -> result
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
