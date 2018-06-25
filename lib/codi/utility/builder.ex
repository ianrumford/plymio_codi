defmodule Plymio.Codi.Utility.Builder do
  @moduledoc false

  require Plymio.Fontais.Option.Macro, as: PFOM
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute
  use Plymio.Codi.Attribute.Builder

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_canonical_keys: 2,
      opts_create_aliases_dict: 1,
      opts_normalise: 1,
      opts_validate: 1,
      opts_fetch: 2,
      opts_get: 3,
      opts_put: 3,
      opts_merge: 1,
      opzioni_merge: 1
    ]

  import Plymio.Funcio.Enum.Map.Collate,
    only: [
      map_collate0_enum: 2,
      map_concurrent_collate0_enum: 2
    ]

  import Plymio.Codi.CPO

  @plymio_codi_builder_opts_kvs_aliases [
    @plymio_codi_builder_alias_getset_namer,
    @plymio_codi_builder_alias_getset_default,
    @plymio_codi_builder_alias_pattern_namer,
    @plymio_codi_builder_alias_pattern_builder
  ]

  @plymio_codi_builder_opts_dict_aliases @plymio_codi_builder_opts_kvs_aliases
                                         |> opts_create_aliases_dict

  def builder_opts_normalise(opts, dict \\ @plymio_codi_builder_opts_dict_aliases) do
    opts |> opts_canonical_keys(dict)
  end

  @plymio_codi_builder_spec_kvs_aliases [
    {@plymio_codi_builder_patterns, [:verbs, :fun, :funs]},
    {@plymio_codi_builder_cpo, []},
    @plymio_codi_builder_alias_getset_namer,
    @plymio_codi_builder_alias_pattern_namer,
    @plymio_codi_builder_alias_pattern_builder
  ]

  @plymio_codi_builder_spec_dict_aliases @plymio_codi_builder_spec_kvs_aliases
                                         |> opts_create_aliases_dict

  def builder_spec_normalise(spec, dict \\ @plymio_codi_builder_spec_dict_aliases) do
    spec |> opts_canonical_keys(dict)
  end

  [
    builder_get_getset_namer: %{
      key: @plymio_codi_builder_getset_namer,
      default: @plymio_fontais_the_unset_value
    },
    builder_get_getset_default: %{
      key: @plymio_codi_builder_getset_default,
      default: %{} |> Macro.escape()
    },
    builder_get_pattern_namer: %{
      key: @plymio_codi_builder_pattern_namer,
      default: @plymio_fontais_the_unset_value
    },
    builder_get_pattern_builder: %{
      key: @plymio_codi_builder_pattern_builder,
      default: @plymio_fontais_the_unset_value
    },
    builder_spec_get_patterns: %{
      key: @plymio_codi_builder_patterns,
      default: []
    },
    builder_spec_get_cpo: %{
      key: @plymio_codi_builder_cpo,
      default: []
    }
  ]
  |> PFOM.def_custom_opts_get()

  [
    builder_fetch_getset_namer: @plymio_codi_builder_getset_namer,
    builder_fetch_pattern_namer: @plymio_codi_builder_pattern_namer,
    builder_fetch_pattern_builder: @plymio_codi_builder_pattern_builder
  ]
  |> PFOM.def_custom_opts_fetch()

  [
    builder_put_getset_namer: @plymio_codi_builder_getset_namer,
    builder_put_getset_default: @plymio_codi_builder_getset_default,
    builder_put_pattern_namer: @plymio_codi_builder_pattern_namer,
    builder_put_pattern_builder: @plymio_codi_builder_pattern_builder
  ]
  |> PFOM.def_custom_opts_put()

  defp pattern_builder_default(cpo, name, pattern)

  defp pattern_builder_default(cpo, _name, _pattern) do
    {:ok, cpo}
  end

  # defp pattern_builder_default(pattern, name, _cpo) do
  #   new_error_result(m: "pattern for name #{inspect name} invalid", v: pattern)
  # end

  def create_struct_getset_patterns(specs, opts \\ [])

  def create_struct_getset_patterns(specs, opts) do
    with {:ok, specs} <- specs |> opts_validate,
         {:ok, opts} <- opts |> builder_opts_normalise,
         {:ok, getset_default} <- opts |> builder_get_getset_default,
         {:ok, pattern_builder} <-
           opts |> builder_get_pattern_builder(&pattern_builder_default/3),

         # build the default spec
         {:ok, spec_opts} <- getset_default |> opts_normalise,
         {:ok, spec_opts} <- spec_opts |> builder_put_pattern_builder(pattern_builder),
         true <- true do
      specs
      |> map_collate0_enum(fn
        {name, spec} when is_atom(name) and is_nil(spec) ->
          {:ok, {name, spec_opts}}

        {name, spec} when is_atom(name) and is_map(spec) ->
          {:ok, {name, spec_opts ++ Map.to_list(spec)}}

        {name, spec} when is_atom(name) and is_list(spec) ->
          with {:ok, spec} <- spec |> opts_normalise do
            {:ok, {name, spec_opts ++ spec}}
          else
            {:error, %{__exception__: true}} = result -> result
          end

        {name, x} ->
          new_error_result(m: "build spec for #{inspect(name)} invalid", v: x)

        x ->
          new_error_result(m: "build spec invalid", v: x)
      end)
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, specs} ->
          specs
          |> map_concurrent_collate0_enum(fn {name, spec} ->
            with {:ok, spec} <- spec |> builder_spec_normalise,
                 {:ok, pattern_builder} <- spec |> builder_fetch_pattern_builder,
                 {:ok, patterns} <- spec |> builder_spec_get_patterns,
                 true <- true do
              patterns
              |> List.wrap()
              |> Enum.uniq()
              |> map_collate0_enum(fn pattern ->
                with {:ok, cpo} <- spec |> builder_spec_get_cpo,
                     {:ok, cpo} <- cpo |> cpo_normalise,
                     {:ok, cpo} <- cpo |> pattern_builder.(name, pattern),
                     {:ok, cpo} <- cpo |> cpo_normalise,
                     true <- true do
                  {:ok, cpo}
                else
                  {:error, %{__exception__: true}} = result -> result
                end
                |> case do
                  {:error, %{__struct__: _}} = result -> result
                  {:ok, name_patterns} -> name_patterns |> opts_merge
                end
              end)
            else
              {:error, %{__exception__: true}} = result -> result
            end
          end)
          |> case do
            {:error, %{__struct__: _}} = result ->
              result

            {:ok, patterns_cpos} ->
              with {:ok, cpos} <- patterns_cpos |> opzioni_merge do
                {:ok, cpos |> Enum.map(fn cpo -> {@plymio_codi_key_pattern, cpo} end)}
              else
                {:error, %{__exception__: true}} = result -> result
              end
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
