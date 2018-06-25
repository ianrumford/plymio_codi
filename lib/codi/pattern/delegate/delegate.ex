defmodule Plymio.Codi.Pattern.Delegate do
  @moduledoc ~S"""
  The *delegate* patterns build `Kernel.defdelegate/2` call(s).

  Delegated functions can be built with, optionally, with a `@doc`,
  `@since` and/or `@spec`.

  See `Plymio.Codi` for an overview and documentation terms

  Note the delegated mfa: `{module, function, arity}` is validated
  i.e. the `function` must exist in the `module` with the given
  `arity`.

  If `:delegate_doc` is not in the pattern opts, a default of
  `:delegate` is used.  (It can be disabled by explicily setting
  `:fun_doc` to `nil` - **not** `false`).

  ## Pattern: *delegate*

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:delegate_module` | *:to, :module, :fun_mod, :fun_module, :function_module* |
  | `:delegate_name` | *:as* |
  | `:delegate_doc` | *:doc, :fun_doc, :function_doc* |
  | `:delegate_args` | *:args, :fun_args, :function_args* |
  | `:delegate_arity` | *:arity, :fun_arity, :function_arity* |
  | `:fun_name` | *:name, :function_name* |
  | `:spec_args` | |
  | `:spec_result` |*:result, :fun_result, :function_result* |
  | `:since` | |

  ## Examples

  A simple case. Note the automatically generated `:delegate`-format `@doc`.

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA],
      ...>   delegate: [name: :fun_due, arity: 2, module: ModuleA],
      ...>   delegate: [name: :fun_tre, arity: 3, module: ModuleA]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Delegated to `ModuleA.fun_one/1`\"",
       "defdelegate(fun_one(var1), to: ModuleA)",
       "@doc \"Delegated to `ModuleA.fun_due/2`\"",
       "defdelegate(fun_due(var1, var2), to: ModuleA)",
       "@doc \"Delegated to `ModuleA.fun_tre/3`\"",
       "defdelegate(fun_tre(var1, var2, var3), to: ModuleA)"]

  Here showing the auto-generated `@doc` disabled.

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA, doc: nil],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["defdelegate(fun_one(var1), to: ModuleA)"]

  This example shows explicit function arguments (`:args`) being given:

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, args: :opts, module: ModuleA, doc: nil],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["defdelegate(fun_one(opts), to: ModuleA)"]

  Delegating to a different function name (`:as`):

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_3, as: :fun_tre, args: [:opts, :key, :value], module: ModuleA, doc: nil],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["defdelegate(fun_3(opts, key, value), to: ModuleA, as: :fun_tre)"]

  Here a `@doc`, `@since`, and `@spec` are generated.  Note in the first
  example the `:spec_args` are explicily given as well as the
  `:spec_result`.  In the second no `:spec_args` are given and the
  arity used.

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA,
      ...>   since: "1.7.9", spec_args: :integer, spec_result: :tuple],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Delegated to `ModuleA.fun_one/1`\"",
       "@since \"1.7.9\"",
       "@spec fun_one(integer) :: tuple",
       "defdelegate(fun_one(var1), to: ModuleA)"]

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA,
      ...>   since: "1.7.9", spec_result: :tuple],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Delegated to `ModuleA.fun_one/1`\"",
       "@since \"1.7.9\"",
       "@spec fun_one(any) :: tuple",
       "defdelegate(fun_one(var1), to: ModuleA)"]

  Showing validation of the `mfa`:

      iex> {:error, error} = [
      ...>   delegate: [name: :fun_one, arity: 2, module: ModuleZ],
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "mfa {ModuleZ, :fun_one, 2} module unknown"

      iex> {:error, error} = [
      ...>   delegate: [name: :fun_1, arity: 2, module: ModuleA],
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "mfa {ModuleA, :fun_1, 2} function unknown"

      iex> {:error, error} = [
      ...>   delegate: [name: :fun_one, arity: 2, module: ModuleA],
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "mfa {ModuleA, :fun_one, 2} arity unknown"

  ## Pattern: *delegate_module*

  The *delegate_module* pattern builds a delegate function
  for one or more functions in a module.

  As with `:delegate`, `@doc` and/or `@since` can be generated at the same time.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:delegate_module` | *:to :module, :fun_module, :fun_mod, :function_module* |
  | `:delegate_doc` | *:doc, :fun_doc, :function_doc* |
  | `:take` |  |
  | `:drop` |  |
  | `:filter` |  |
  | `:reject` |  |
  | `:since` | |

  To determine which functions to delegate, the "function v arity"
  (*fva*) for the module is first obtained by calling e.g. `ModuleA.__info__(:functions)`.

  The *delegate options* can include `:take`, `:drop`, `:filter` or
  `:reject` keys to "edit" the *fva*..

  The first two take zero, one or more function names
  and are used in a call to e.g. `Keyword.take/2` with the *fva*.

  The second two keys require an arity 1 function (predicate) passed a
  `{fun,arity}` tuple, returning `true` or `false` and is used with e.g. `Enum.filter/2`.

  > Note the fva edits are applied in order of occurence so `:take`-ing a function already `:reject`-ed will do nothing.

  Here all functions in the module (`ModuleA`) are wanted with auto-generated `@doc` and `@since`:

      iex> {:ok, {forms, _}} = [
      ...>   delegate_module: [module: ModuleA, since: "1.7.9"],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["@doc \"Delegated to `ModuleA.fun_due/2`\"",
       "@since \"1.7.9\"",
       "defdelegate(fun_due(var1, var2), to: ModuleA)",
       "@doc \"Delegated to `ModuleA.fun_one/1`\"",
       "@since \"1.7.9\"",
       "defdelegate(fun_one(var1), to: ModuleA)",
       "@doc \"Delegated to `ModuleA.fun_tre/3`\"",
       "@since \"1.7.9\"",
       "defdelegate(fun_tre(var1, var2, var3), to: ModuleA)"]

  Here arity 2 funs are selected, and `@doc` is disabled.

      iex> {:ok, {forms, _}} = [
      ...>   delegate_module: [
      ...>     module: ModuleA, doc: nil,
      ...>     filter: fn {_fun,arity} -> arity == 3 end],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_format_forms!
      ["defdelegate(fun_tre(var1, var2, var3), to: ModuleA)"]

  """

  alias Plymio.Codi, as: CODI
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Option,
    only: [
      opts_canonical_keys: 2,
      opts_take_canonical_keys: 2,
      opts_create_aliases_dict: 1
    ]

  import Plymio.Codi.Utility,
    only: [
      cpo_resolve_fun_name: 1,
      cpo_resolve_delegate_module: 1,
      cpo_resolve_delegate_name: 1,
      cpo_resolve_delegate_doc: 1,
      cpo_resolve_delegate_args: 1
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

  @pattern_delegate_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_since,
    @plymio_codi_key_alias_fun_name,
    @plymio_codi_key_alias_delegate_doc,
    @plymio_codi_key_alias_delegate_module,
    @plymio_codi_key_alias_delegate_name,
    @plymio_codi_key_alias_delegate_args,
    @plymio_codi_key_alias_delegate_arity,

    # limited aliases
    {@plymio_codi_key_typespec_spec_args, [:spec_args]},
    @plymio_codi_key_alias_typespec_spec_result,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_delegate_dict_alias @pattern_delegate_kvs_alias
                               |> opts_create_aliases_dict

  @doc false

  def cpo_pattern_delegate_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_delegate_dict_alias)
  end

  @pattern_delegate_module_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_since,
    @plymio_codi_key_alias_delegate_module,
    @plymio_codi_key_alias_delegate_doc,
    {@plymio_codi_key_take, nil},
    {@plymio_codi_key_drop, nil},
    {@plymio_codi_key_filter, nil},
    {@plymio_codi_key_reject, nil},
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_delegate_module_dict_alias @pattern_delegate_module_kvs_alias
                                      |> opts_create_aliases_dict

  @doc false

  def cpo_pattern_delegate_module_normalise(opts, dict \\ nil) do
    opts |> opts_canonical_keys(dict || @pattern_delegate_module_dict_alias)
  end

  @doc false

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_delegate do
    with {:ok, cpo} <- cpo |> cpo_pattern_delegate_normalise,
         {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, delegate_module} <- cpo |> cpo_resolve_delegate_module,
         {:ok, cpo} <- cpo |> cpo_maybe_put_delegate_name(fun_name),
         {:ok, delegate_name} <- cpo |> cpo_resolve_delegate_name,
         {:ok, delegate_args} <- cpo |> cpo_resolve_delegate_args,
         {:ok, cpo} <- cpo |> cpo_maybe_put_delegate_doc(@plymio_codi_doc_type_delegate),
         {:ok, delegate_doc} <- cpo |> cpo_resolve_delegate_doc,
         {:ok, {_, %CODI{} = state}} <-
           state |> state_validate_mfa({delegate_module, delegate_name, length(delegate_args)}),

         # base dependent cpo
         {:ok, depend_cpo} <- cpo |> cpo_mark_status_active,
         {:ok, depend_cpo} <- depend_cpo |> cpo_put_fun_module(delegate_module),

         # the dependent doc cpo
         {:ok, depend_doc_cpo} <- depend_cpo |> cpo_put_pattern(@plymio_codi_pattern_doc),
         {:ok, depend_doc_cpo} <- depend_doc_cpo |> cpo_put_fun_doc(delegate_doc),
         {:ok, depend_doc_cpo} <- depend_doc_cpo |> cpo_put_fun_args(delegate_args),

         # the dependent since cpo
         {:ok, depend_since_cpo} <- depend_cpo |> cpo_put_pattern(@plymio_codi_pattern_since),

         # the dependent type cpo
         {:ok, depend_type_cpo} <-
           depend_cpo |> cpo_put_pattern(@plymio_codi_pattern_typespec_spec),
         {:ok, depend_type_cpo} <-
           depend_type_cpo
           |> cpo_maybe_add_typespec_spec_opts([
             {@plymio_codi_key_typespec_spec_arity, delegate_args |> length}
           ]),
         true <- true do
      delegate_opts =
        (delegate_name == fun_name)
        |> case do
          true ->
            [to: delegate_module]

          _ ->
            [to: delegate_module, as: delegate_name]
        end

      pattern_form =
        quote do
          defdelegate unquote(fun_name)(unquote_splicing(delegate_args)), unquote(delegate_opts)
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
      when pattern == @plymio_codi_pattern_delegate_module do
    with {:ok, opts} <- opts |> cpo_pattern_delegate_module_normalise,
         {:ok, delegate_module} <- opts |> cpo_fetch_delegate_module,
         {:ok, {delegate_fva, %CODI{} = state}} <-
           state |> state_resolve_module_fva(delegate_module),
         {:ok, delegate_fva} <- delegate_fva |> reduce_module_fva(opts),
         {:ok, delegate_cpo} <- opts |> cpo_pattern_delegate_normalise,
         {:ok, delegate_cpo} <- delegate_cpo |> cpo_mark_status_active,
         {:ok, delegate_cpo} <- delegate_cpo |> cpo_put_pattern(@plymio_codi_pattern_delegate) do
      delegate_fva
      |> map_collate0_enum(fn {name, arity} ->
        with {:ok, cpo} <- delegate_cpo |> cpo_put_fun_name(name),
             {:ok, cpo} <- cpo |> cpo_put_delegate_name(name),
             {:ok, _cpo} = result <- cpo |> cpo_put_delegate_arity(arity) do
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
