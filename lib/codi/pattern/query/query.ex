defmodule Plymio.Codi.Pattern.Query do
  # @moduledoc false

  @moduledoc ~S"""
  The *query* patterns build query functions
  (e.g. `myfun?(arg)`) using existing base functions (e.g. `myfun(arg)`).

  When the base function returns `{:ok, value}`, the query
  function returns `true`. Otherwise `false` is returned.

  Query functions can be built with, optionally, with a `@doc`, `@since`
  and/or `@spec`.

  See `Plymio.Codi` for an overview and documentation terms.

  Note if the base function is in another module, the base mfa
  `{module, function, arity}` is validated i.e. the `function` must
  exist in the `module` with the given `arity`.

  If `:fun_doc` is not in the pattern opts, a default of `:query` is
  used.  (It can be disabled by explicitly setting `:fun_doc` to
  `nil`)

  ## Pattern: *query*

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:query_module` | *:module, :fun_mod, :query_module, :function_module* |
  | `:query_name` | *:name, :fun_name, :function_name* |
  | `:query_args` | *:args, :fun_args, :function_args* |
  | `:query_arity` | *:arity, :fun_arity, :function_arity* |
  | `:query_doc` | *:doc, :fun_doc, :function_doc* |
  | `:typespec_spec_spec_args` |*:spec_args* |
  | `:typespec_spec_result` |*::result, :spec_result, :fun_result, :function_result* |
  | `:since` | |

  ## Examples

  Here is the common case of a query function for a function in the
  same module. Note the automatically generated `:query`-format `@doc`
  and explicitly specified `@since`:

      iex> {:ok, {forms, _}} = [
      ...>   query: [as: :fun_tre, arity: 3, since: "1.7.9"]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Query function for `fun_tre/3`\"",
       "@since \"1.7.9\"",
       "def(fun_tre?(var1, var2, var3)) do",
       "  case(fun_tre(var1, var2, var3)) do",
       "    {:ok, _} ->",
       "      true",
       "",
       "    _ ->",
       "      false",
       "  end",
       "end"]

  Here the other function is in a different module(`ModuleA`):

      iex> {:ok, {forms, _}} = [
      ...>   query: [as: :fun_tre, arity: 3, to: ModuleA, since: "1.7.9"]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Query function for `ModuleA.fun_tre/3`\"",
       "@since \"1.7.9\"",
       "def(fun_tre?(var1, var2, var3)) do",
       "  case(ModuleA.fun_tre(var1, var2, var3)) do",
       "    {:ok, _} ->",
       "      true",
       "",
       "    _ ->",
       "      false",
       "  end",
       "end"]

  The `:fun_args` can be supplied to improve the definition. Note the
  `:fun_doc` is set to `false`.

      iex> {:ok, {forms, _}} = [
      ...>   query: [as: :fun_tre, args: [:x, :y, :z], to: ModuleA, fun_doc: false]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc false",
       "def(fun_tre?(x, y, z)) do",
       "  case(ModuleA.fun_tre(x, y, z)) do",
       "    {:ok, _} ->",
       "      true", "",
       "    _ ->",
       "      false",
       "  end",
       "end"]

  Similary, if the *cpo* contains a `:spec_result` key, a `@spec` will
  be generated. The second example has an explicit `:spec_args`

  > note the @spec result is always boolean and any given value will be ignored.

      iex> {:ok, {forms, _}} = [
      ...>   query: [as: :fun_tre, args: [:x, :y, :z], module: ModuleA, result: true]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Query function for `ModuleA.fun_tre/3`\"",
       "@spec fun_tre?(any, any, any) :: boolean",
       "def(fun_tre?(x, y, z)) do",
       "  case(ModuleA.fun_tre(x, y, z)) do",
       "    {:ok, _} ->",
       "      true",
       "",
       "    _ ->",
       "      false",
       "  end",
       "end"]

      iex> {:ok, {forms, _}} = [
      ...>   query: [as: :fun_tre, args: [:x, :y, :z], module: ModuleA,
      ...>          spec_args: [:integer, :binary, :atom], result: :tuple]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Query function for `ModuleA.fun_tre/3`\"",
       "@spec fun_tre?(integer, binary, atom) :: boolean",
       "def(fun_tre?(x, y, z)) do",
       "  case(ModuleA.fun_tre(x, y, z)) do",
       "    {:ok, _} ->",
       "      true", "",
       "    _ ->",
       "      false",
       "  end",
       "end"]

  ## Pattern: *query_module*

  The *query_module* pattern builds a query function for one or more
  functions in a module. As with `:query` a `@doc` or `@since` can be generated at
  the same time.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:query_module` | *:to, :module, :fun_mod, :fun_module, :function_module* |
  | `:query_doc` | *:doc, :fun_doc, :function_doc* |
  | `:take` |  |
  | `:drop` |  |
  | `:filter` |  |
  | `:reject` |  |
  | `:since` | |

  ## Examples

  Here a query function will be generated for all the functions in the module.

      iex> {:ok, {forms, _}} = [
      ...>   query_module: [module: ModuleA],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Query function for `ModuleA.fun_due/2`\"",
       "def(fun_due?(var1, var2)) do",
       "  case(ModuleA.fun_due(var1, var2)) do",
       "    {:ok, _} ->",
       "      true",
       "",
       "    _ ->",
       "      false",
       "  end",
       "end",
       "@doc \"Query function for `ModuleA.fun_one/1`\"",
       "def(fun_one?(var1)) do", "  case(ModuleA.fun_one(var1)) do",
       "    {:ok, _} ->",
       "      true",
       "", "    _ ->", "      false",
       "  end", "end", "@doc \"Query function for `ModuleA.fun_tre/3`\"",
       "def(fun_tre?(var1, var2, var3)) do",
       "  case(ModuleA.fun_tre(var1, var2, var3)) do",
       "    {:ok, _} ->",
       "      true",
       "",
       "    _ ->",
       "      false",
       "  end",
       "end"]

  In the same way as `:bang_module` the functions can be selected
  using e.g. `:take`. Here `:since` is also given.

      iex> {:ok, {forms, _}} = [
      ...>   query_module: [module: ModuleA, take: :fun_due, since: "1.7.9"],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Query function for `ModuleA.fun_due/2`\"",
       "@since \"1.7.9\"",
       "def(fun_due?(var1, var2)) do",
       "  case(ModuleA.fun_due(var1, var2)) do",
       "    {:ok, _} ->",
       "      true",
       "",
       "    _ ->",
       "      false",
       "  end",
       "end"]

  """

  alias Plymio.Codi, as: CODI
  alias Plymio.Codi.Utility.Depend, as: DEPEND
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_value_unset_or_nil: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_canonical_keys: 2,
      opts_take_canonical_keys: 2,
      opts_create_aliases_dict: 1
    ]

  import Plymio.Codi.Utility,
    only: [
      cpo_resolve_query_module: 1,
      cpo_resolve_query_name: 1,
      cpo_resolve_query_args: 1,
      cpo_resolve_query_doc: 1,
      cpo_resolve_fun_name: 1
    ]

  import Plymio.Codi.Utility.Module,
    only: [
      reduce_module_fva: 2,
      state_validate_mfa: 2,
      state_resolve_module_fva: 2
    ]

  import Plymio.Funcio.Enum.Map.Collate,
    only: [
      map_collate0_enum: 2
    ]

  import Plymio.Codi.CPO

  @pattern_query_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_since,
    @plymio_codi_key_alias_query_module,
    @plymio_codi_key_alias_query_name,
    @plymio_codi_key_alias_query_doc,
    @plymio_codi_key_alias_query_args,
    @plymio_codi_key_alias_query_arity,
    @plymio_codi_key_alias_fun_name,

    # limited aliases
    {@plymio_codi_key_typespec_spec_args, [:spec_args]},
    @plymio_codi_key_alias_typespec_spec_result,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_query_dict_alias @pattern_query_kvs_alias
                            |> opts_create_aliases_dict

  @doc false
  def cpo_pattern_query_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_query_dict_alias)
  end

  @pattern_query_module_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_since,
    @plymio_codi_key_alias_query_module,
    @plymio_codi_key_alias_query_name,
    @plymio_codi_key_alias_query_doc,
    {@plymio_codi_key_take, nil},
    {@plymio_codi_key_drop, nil},
    {@plymio_codi_key_filter, nil},
    {@plymio_codi_key_reject, nil},
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_query_module_dict_alias @pattern_query_module_kvs_alias
                                   |> opts_create_aliases_dict

  @doc false
  def cpo_pattern_query_module_normalise(opts, dict \\ nil) do
    opts |> opts_canonical_keys(dict || @pattern_query_module_dict_alias)
  end

  @doc false

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_query do
    with {:ok, cpo} <- cpo |> cpo_pattern_query_normalise,
         {:ok, query_module} <- cpo |> cpo_resolve_query_module,
         {:ok, query_name} <- cpo |> cpo_resolve_query_name,
         {:ok, query_args} <- cpo |> cpo_resolve_query_args,
         {:ok, cpo} <- cpo |> cpo_maybe_put_query_doc(@plymio_codi_doc_type_query),
         {:ok, query_doc} <- cpo |> cpo_resolve_query_doc,
         {:ok, cpo} <- cpo |> cpo_maybe_put_fun_name("#{query_name}?" |> String.to_atom()),
         {:ok, real_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, {_, %CODI{} = state}} <-
           state |> state_validate_mfa({query_module, query_name, length(query_args)}),

         # base dependent cpo
         {:ok, depend_cpo} <- cpo |> cpo_put_fun_module(query_module),
         {:ok, depend_cpo} <- depend_cpo |> cpo_put_fun_doc(query_doc),
         {:ok, depend_cpo} <- depend_cpo |> cpo_put_fun_arity(length(query_args)),
         true <- true do
      pattern_form =
        query_module
        |> case do
          # local function
          x when is_value_unset_or_nil(x) ->
            quote do
              def unquote(real_name)(unquote_splicing(query_args)) do
                case unquote(query_name)(unquote_splicing(query_args)) do
                  {:ok, _} -> true
                  _ -> false
                end
              end
            end

          # explicit module
          _ ->
            quote do
              def unquote(real_name)(unquote_splicing(query_args)) do
                case unquote(query_module).unquote(query_name)(unquote_splicing(query_args)) do
                  {:ok, _} -> true
                  _ -> false
                end
              end
            end
        end

      depend_args = [
        {&cpo_has_fun_doc?/1,
         [
           &DEPEND.cpo_transform_doc_depend/1,
           # the doc fun name is the query fun
           {:cpo_put_fun_name, query_name}
         ]},
        {&cpo_has_since?/1, &DEPEND.cpo_transform_since_depend/1},
        {&cpo_has_typespec_spec_opts?/1,
         [
           &DEPEND.cpo_transform_typespec_spec_depend/1,
           # always boolean
           {:cpo_put_typespec_spec_result, :boolean}
         ]}
      ]

      with {:ok, cpo} <- cpo |> cpo_done_with_edited_form(pattern_form),
           {:ok, {depend_cpos, %CODI{}}} <-
             state |> DEPEND.create_depend_cpos(depend_cpo, depend_args) do
        cpos = depend_cpos ++ [cpo]

        {:ok, {cpos, state}}
      else
        {:error, %{__exception__: true}} = result -> result
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def express_pattern(%CODI{} = state, pattern, opts)
      when pattern == @plymio_codi_pattern_query_module do
    with {:ok, opts} <- opts |> cpo_pattern_query_module_normalise,
         {:ok, query_module} <- opts |> cpo_resolve_query_module,
         {:ok, {query_fva, %CODI{} = state}} <- state |> state_resolve_module_fva(query_module),
         {:ok, query_fva} <- query_fva |> reduce_module_fva(opts),
         {:ok, query_cpo} <- opts |> cpo_pattern_query_normalise,
         {:ok, query_cpo} <- query_cpo |> cpo_mark_status_active,
         {:ok, query_cpo} <- query_cpo |> cpo_put_pattern(@plymio_codi_pattern_query) do
      query_fva
      |> map_collate0_enum(fn {name, arity} ->
        with {:ok, cpo} <- query_cpo |> cpo_put_query_name(name),
             {:ok, _cpo} = result <- cpo |> cpo_put_query_arity(arity) do
          result
        else
          {:error, %{__exception__: true}} = result -> result
        end
      end)
      |> case do
        {:error, %{__struct__: _}} = result -> result
        {:ok, cpos} -> {:ok, {cpos, state}}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
