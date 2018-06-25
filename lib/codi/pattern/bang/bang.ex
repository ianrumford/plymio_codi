defmodule Plymio.Codi.Pattern.Bang do
  @moduledoc ~S"""
  The *bang* patterns builds bang functions
  (e.g. `myfun!(arg)`) using existing base functions (e.g. `myfun(arg)`).

  When the base function returns `{:ok, value}`, the bang
  function returns `value`.

  If the base function returns `{:error, error}`, the `error` is raised.

  Bang functions can be built with, optionally, with a `@doc`, `@since`
  and/or `@spec`.

  See `Plymio.Codi` for an overview and documentation terms.

  Note if the base function is in another module, the base mfa
  `{module, function, arity}` is validated i.e. the `function` must
  exist in the `module` with the given `arity`.

  If `:fun_doc` is not in the pattern opts, a default of `:bang` is
  used.  (It can be disabled by explicitly setting `:fun_doc` to
  `nil`)

  ## Pattern: *bang*

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:bang_module` | *:module, :fun_mod, :bang_module, :function_module* |
  | `:bang_name` | *:name, :fun_name, :function_name* |
  | `:bang_args` | *:args, :fun_args, :function_args* |
  | `:bang_arity` | *:arity, :fun_arity, :function_arity* |
  | `:bang_doc` | *:doc, :fun_doc, :function_doc* |
  | `:spec_args` | |
  | `:spec_result` |*:result, :fun_result, :function_result* |
  | `:since` | |

  ## Examples

  Here is the common case of a bang function for a function in the
  same module. Note the automatically generated `:bang`-format `@doc`
  and explicitly specified `@since`:

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, arity: 3, since: "1.7.9"]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Bang function for `fun_tre/3`\"",
       "@since \"1.7.9\"",
       "def(fun_tre!(var1, var2, var3)) do",
       "  case(fun_tre(var1, var2, var3)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  Here the other function is in a different module(`ModuleA`):

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, arity: 3, to: ModuleA, since: "1.7.9"]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_tre/3`\"",
       "@since \"1.7.9\"",
       "def(fun_tre!(var1, var2, var3)) do",
       "  case(ModuleA.fun_tre(var1, var2, var3)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  The `:fun_args` can be supplied to improve the definition. Note the `:fun_doc` is set to `false`.

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, args: [:x, :y, :z], to: ModuleA, fun_doc: false]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc false", "def(fun_tre!(x, y, z)) do",
       "  case(ModuleA.fun_tre(x, y, z)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  Similary, if the *cpo* contains a `:spec_result` key, a `@spec` will
  be generated. The second example has an explicit `:spec_args`

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, args: [:x, :y, :z], module: ModuleA, result: :tuple]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_tre/3`\"",
       "@spec fun_tre!(any, any, any) :: tuple",
       "def(fun_tre!(x, y, z)) do",
       "  case(ModuleA.fun_tre(x, y, z)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, args: [:x, :y, :z], module: ModuleA,
      ...>          spec_args: [:integer, :binary, :atom], result: :tuple]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_tre/3`\"",
       "@spec fun_tre!(integer, binary, atom) :: tuple",
       "def(fun_tre!(x, y, z)) do",
       "  case(ModuleA.fun_tre(x, y, z)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  ## Pattern: *bang_module*

  The *bang_module* pattern builds a bang function for one or more
  functions in a module. As with `:bang` a `@doc` or `@since` can be generated at
  the same time.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:bang_module` | *:to, :module, :fun_mod, :fun_module, :function_module* |
  | `:bang_doc` | *:doc, :fun_doc, :function_doc* |
  | `:take` |  |
  | `:drop` |  |
  | `:filter` |  |
  | `:reject` |  |
  | `:since` | |

  ## Examples

  Here a bang function will be generated for all the functions in the module.

      iex> {:ok, {forms, _}} = [
      ...>   bang_module: [module: ModuleA],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_due/2`\"",
       "def(fun_due!(var1, var2)) do",
       "  case(ModuleA.fun_due(var1, var2)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end",
       "@doc \"Bang function for `ModuleA.fun_one/1`\"",
       "def(fun_one!(var1)) do", "  case(ModuleA.fun_one(var1)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end",
       "@doc \"Bang function for `ModuleA.fun_tre/3`\"",
       "def(fun_tre!(var1, var2, var3)) do",
       "  case(ModuleA.fun_tre(var1, var2, var3)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  In the same way as `:delegate_module` the functions can be selected
  using e.g. `:take`. Here `:since` is also given.

      iex> {:ok, {forms, _}} = [
      ...>   bang_module: [module: ModuleA, take: :fun_due, since: "1.7.9"],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_due/2`\"",
       "@since \"1.7.9\"",
       "def(fun_due!(var1, var2)) do",
       "  case(ModuleA.fun_due(var1, var2)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  """

  alias Plymio.Codi, as: CODI
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
      cpo_resolve_bang_module: 1,
      cpo_resolve_bang_name: 1,
      cpo_resolve_bang_args: 1,
      cpo_resolve_bang_doc: 1,
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

  @pattern_bang_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_since,
    @plymio_codi_key_alias_bang_module,
    @plymio_codi_key_alias_bang_name,
    @plymio_codi_key_alias_bang_doc,
    @plymio_codi_key_alias_bang_args,
    @plymio_codi_key_alias_bang_arity,
    @plymio_codi_key_alias_fun_name,

    # limited aliases
    {@plymio_codi_key_typespec_spec_args, [:spec_args]},
    @plymio_codi_key_alias_typespec_spec_result,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_bang_dict_alias @pattern_bang_kvs_alias
                           |> opts_create_aliases_dict

  @doc false
  def cpo_pattern_bang_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_bang_dict_alias)
  end

  @pattern_bang_module_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_since,
    @plymio_codi_key_alias_bang_module,
    @plymio_codi_key_alias_bang_name,
    @plymio_codi_key_alias_bang_doc,
    {@plymio_codi_key_take, nil},
    {@plymio_codi_key_drop, nil},
    {@plymio_codi_key_filter, nil},
    {@plymio_codi_key_reject, nil},
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_bang_module_dict_alias @pattern_bang_module_kvs_alias
                                  |> opts_create_aliases_dict

  @doc false

  def cpo_pattern_bang_module_normalise(opts, dict \\ nil) do
    opts |> opts_canonical_keys(dict || @pattern_bang_module_dict_alias)
  end

  @doc false

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_bang do
    with {:ok, cpo} <- cpo |> cpo_pattern_bang_normalise,
         {:ok, bang_module} <- cpo |> cpo_resolve_bang_module,
         {:ok, bang_name} <- cpo |> cpo_resolve_bang_name,
         {:ok, bang_args} <- cpo |> cpo_resolve_bang_args,
         {:ok, cpo} <- cpo |> cpo_maybe_put_bang_doc(@plymio_codi_doc_type_bang),
         {:ok, bang_doc} <- cpo |> cpo_resolve_bang_doc,
         {:ok, cpo} <- cpo |> cpo_maybe_put_fun_name("#{bang_name}!" |> String.to_atom()),
         {:ok, real_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, {_, %CODI{} = state}} <-
           state |> state_validate_mfa({bang_module, bang_name, length(bang_args)}),

         # base dependent cpo
         {:ok, depend_cpo} <- cpo |> cpo_mark_status_active,
         {:ok, depend_cpo} <- depend_cpo |> cpo_put_fun_module(bang_module),
         {:ok, depend_cpo} <- depend_cpo |> cpo_put_fun_doc(bang_doc),
         # delete the fun_args to stop confusion over type args; fun_arity will be used if needed
         {:ok, depend_cpo} <- depend_cpo |> cpo_drop_fun_args,

         # the dependent doc cpo
         {:ok, depend_doc_cpo} <- depend_cpo |> cpo_put_pattern(@plymio_codi_pattern_doc),
         {:ok, depend_doc_cpo} <- depend_doc_cpo |> cpo_put_fun_arity(length(bang_args)),
         {:ok, depend_doc_cpo} <- depend_doc_cpo |> cpo_put_fun_name(bang_name),

         # the dependent since cpo
         {:ok, depend_since_cpo} <- depend_cpo |> cpo_put_pattern(@plymio_codi_pattern_since),

         # the dependent type cpo
         {:ok, depend_type_cpo} <-
           depend_cpo |> cpo_put_pattern(@plymio_codi_pattern_typespec_spec),
         {:ok, depend_type_cpo} <-
           depend_type_cpo
           |> cpo_maybe_add_typespec_spec_opts([
             {@plymio_codi_key_typespec_spec_arity, length(bang_args)}
           ]),
         {:ok, depend_type_cpo} <- depend_type_cpo |> cpo_put_fun_name(real_name) do
      pattern_form =
        bang_module
        |> case do
          # local function
          x when is_value_unset_or_nil(x) ->
            quote do
              def unquote(real_name)(unquote_splicing(bang_args)) do
                case unquote(bang_name)(unquote_splicing(bang_args)) do
                  {:ok, value} -> value
                  {:error, error} -> raise error
                end
              end
            end

          # explicit module
          _ ->
            quote do
              def unquote(real_name)(unquote_splicing(bang_args)) do
                case unquote(bang_module).unquote(bang_name)(unquote_splicing(bang_args)) do
                  {:ok, value} -> value
                  {:error, error} -> raise error
                end
              end
            end
        end

      depend_patterns = [
        depend_doc_cpo,
        depend_since_cpo,
        depend_type_cpo
      ]

      with {:ok, %CODI{} = depend_state} <- state |> CODI.update_snippets(depend_patterns),
           {:ok, {depend_product, %CODI{}}} <-
             depend_state |> Plymio.Codi.Stage.Normalise.normalise_snippets(),
           {:ok, depend_cpos} <- depend_product |> cpo_fetch_patterns,
           {:ok, cpo} <- cpo |> cpo_done_with_edited_form(pattern_form) do
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
      when pattern == @plymio_codi_pattern_bang_module do
    with {:ok, opts} <- opts |> cpo_pattern_bang_module_normalise,
         {:ok, bang_module} <- opts |> cpo_resolve_bang_module,
         {:ok, {bang_fva, %CODI{} = state}} <- state |> state_resolve_module_fva(bang_module),
         {:ok, bang_fva} <- bang_fva |> reduce_module_fva(opts),
         {:ok, bang_cpo} <- opts |> cpo_pattern_bang_normalise,
         {:ok, bang_cpo} <- bang_cpo |> cpo_mark_status_active,
         {:ok, bang_cpo} <- bang_cpo |> cpo_put_pattern(@plymio_codi_pattern_bang) do
      bang_fva
      |> map_collate0_enum(fn {name, arity} ->
        with {:ok, cpo} <- bang_cpo |> cpo_put_bang_name(name),
             {:ok, _cpo} = result <- cpo |> cpo_put_bang_arity(arity) do
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
