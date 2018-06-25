defmodule Plymio.Codi do
  @moduledoc ~S"""
  `Plymio.Codi` generates *quoted forms* for common code *patterns*.

  The `produce_codi/2` function produces the *quoted forms* for the
  *patterns*.

  The `reify_codi/2` macro calls `produce_codi/2` and then compiles
  the forms.

  ## Documentation Terms

  In the documentation below these terms, usually in *italics*, are used to mean the same thing.

  ### *opts*

  *opts* is a `Keyword` list.

  ### *form* and *forms*

  A *form* is a quoted form (`Macro.t`). A *forms* is a list of zero, one or more *form*s.

  ### *vekil*

  The proxy patterns (see below) use a dictionary called the *vekil*:
  The *proxy* can be though of as the *key* while its value (called a
  *from*) "realises" to a *form* / *forms*.

  The *vekil* implements the `Plymio.Vekil` protocol. If the vekil
  given to `new/1` or `update/2` is a `Map` or `Keyword`, it will be
  used to create a `Plymio.Vekil.Form` *vekil*.

  The *forom* in the *vekil* **must** "realise"
  (`Plymio.Vekil.Forom.realise/2`) to *forms*.

  It is more efficient to pre-create (ideally at compile time) the
  *vekil*; it can be edited later using e.g. `:proxy_put`.

  ## Options (*opts*)

  The first argument to both of these functions is an *opts*.

  The canonical form of a *pattern* definition in the *opts* is the
  key `:pattern` with an *opts* value specific to the
  *pattern* e.g.

        [pattern: [pattern: :delegate, name: :fun_one, arity: 1, module: ModuleA]

  The value is referred to as the *cpo* below, short for *codi pattern opts*.

  **All pattern definitions are normalised to this format.**

  However, for convenience, the key can be the *pattern* name
  (e.g. `:delegate`) and the value the (pre normalised) *cpo*:

        [delegate: [name: :fun_one, arity: 1, module: ModuleA]

  This example shows the code produced for the above:

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA],
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@doc(\"Delegated to `ModuleA.fun_one/1`\")",
       "defdelegate(fun_one(var1), to: ModuleA)"]

  Also, again for convenience, some *patterns* will normalise the
  value.  For example the `:doc` pattern normalises this:

      [doc: "This is a docstring"]

  into this:

      [pattern: [pattern: doc, doc: "This is a docstring"]

  The keys in the *cpo* have aliases. Note the aliases are
  pattern-specific. For examples `:args` is both an alias for
  `:spec_args` and `:fun_args`. Each pattern below lists its keys' aliases.

  ### Common Codi Pattern Opts Keys

  These are the keys that can appear in a *cpo* as well as the pattern-specific ones:

  | Key | Aliases | Role |
  | :---  | :--- | :--- |
  | `:pattern` |  | *the name of the pattern* |
  | `:forms_edit` | *:form_edit, :edit_forms, :edit_form* | *forms_edit/2 opts* |

  > there are other, internal use, keys that can appear as well.

  ## Editing Pattern Forms

  Most patterns produce *forms*. Individual pattern *forms* can be edited by giving a `:forms_edit` key in the *cpo*
  where the value is an *opts* understood by `Plymio.Fontais.Form.forms_edit/2`.

  Alternatively the `:forms_edit` can be given in the *opts* to
  `produce_codi/2` (or `reify_codi/2`) and will be applied to *all*
  produced *forms*.

  ## Patterns

  There are a number of patterns, some having aliases, described below:

  | Pattern | Aliases |
  | :---  | :--- |
  | `:form` | *:forms, :ast, :asts* |
  | `:typespec_spec` | *:spec* |
  | `:doc` | |
  | `:since` | |
  | `:delegate` |  |
  | `:delegate_module` |  |
  | `:bang` |  |
  | `:bang_module` |  |
  | `:query` |  |
  | `:query_module` |  |
  | `:proxy_fetch` | *:proxy, :proxies, :proxies_fetch* |
  | `:proxy_put` | *:proxies_put* |
  | `:proxy_delete` | *:proxies_delete* |
  | `:proxy_get` | *:proxies_get* |
  | `:struct_get` | |
  | `:struct_fetch` | |
  | `:struct_put` | |
  | `:struct_maybe_put` | |
  | `:struct_has?` | |
  | `:struct_update` | |
  | `:struct_set` | |
  | `:struct_export` | |

  ### Pattern: *form*

  The *form* pattern is a convenience to embed arbitrary code.

  See `Plymio.Codi.Pattern.Other` for details and examples.

  ### Pattern: *typespec_spec*

  The *typespec_spec* pattern builds a `@spec` module attribute form.

  See `Plymio.Codi.Pattern.Typespec` for details and examples.

  ### Pattern: *doc*

  The *doc* pattern builds a `@doc` module attribute form.

  See `Plymio.Codi.Pattern.Doc` for details and examples.

  ### Pattern: *since*

  The *since* pattern builds a `@since` module attribute form.

  See `Plymio.Codi.Pattern.Other` for details and examples.

  ### Pattern: *deprecated*

  The *deprecated* pattern builds a `@deprecated` module attribute form.

  See `Plymio.Codi.Pattern.Other` for details and examples.

  ### Pattern: *delegate* and *delegate_module*

  The *delegate* pattern builds a `Kernel.defdelegate/2` call,
  together, optionally, with a `@doc`, `@since`, and/or `@spec`.

  The *delegate_module* pattern builds a `Kernel.defdelegate/2` call
  for one or more functions in a module. As with `:delegate` a `@doc` and/or `@since`
  can be generated at the same time.

  See `Plymio.Codi.Pattern.Delegate` for details and examples.

  ### Pattern: *bang* and *bang_module*

  The *bang* pattern builds bang functions
  (e.g. `myfun!(arg)`) using existing base functions (e.g. `myfun(arg)`).

  The *bang_module* pattern builds a bang function for one or more
  functions in a module. As with `:bang` a `@doc` or `@since` can be generated at
  the same time.

  See `Plymio.Codi.Pattern.Bang` for details and examples.

  ### Pattern: *query* and *query_module*

  The *query* pattern works like *bang* but builds a query function
  (e.g. `myfun?(arg)`) using a base function (e.g. `myfun(arg)`).

  The *query_module* pattern builds a query function for one or more
  functions in a module. As with `:query` a `@doc` or `@since` can be generated at
  the same time.

  See `Plymio.Codi.Pattern.Query` for details and examples.

  ### Pattern: *proxy* patterns

  The *proxy* patterns manage the *vekil*..

  See `Plymio.Codi.Pattern.Proxy` for details and examples.

  ### Pattern: *struct* patterns

  The *struct* patterns create a range of transform functions for a module's struct.

  See `Plymio.Codi.Pattern.Struct` for details and examples.

  """

  require Plymio.Vekil.Utility, as: VEKILUTIL
  require Plymio.Fontais.Option, as: PFO
  use Plymio.Fontais.Attribute
  use Plymio.Vekil.Attribute
  use Plymio.Codi.Attribute

  @codi_opts [
    {@plymio_vekil_key_vekil, Plymio.Vekil.Codi.__vekil__()}
  ]

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ],
    warn: false

  import Plymio.Fontais.Guard,
    only: [
      is_value_set: 1,
      is_value_unset: 1,
      is_value_unset_or_nil: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opzioni_flatten: 1,
      opts_create_aliases_dict: 1
    ]

  import Plymio.Codi.Utility.Dispatch,
    only: [
      validate_pattern_dispatch_vector: 1
    ]

  import Plymio.Codi.Utility,
    only: [
      validate_module_dict: 1,
      validate_fun_module: 1
    ],
    warn: false

  import Plymio.Codi.CPO,
    only: [
      cpo_get_status: 2,
      cpo_get_patterns: 1,
      cpo_put_set_struct_field: 3,
      cpo_edit_forms: 1
    ]

  import Plymio.Funcio.Enum.Map.Collate,
    only: [
      map_collate0_enum: 2
    ]

  @plymio_codi_pattern_dicts @plymio_fontais_the_unset_value

  @plymio_codi_pattern_normalisers %{
    @plymio_codi_pattern_form => &Plymio.Codi.Pattern.Other.cpo_pattern_form_normalise/1,
    @plymio_codi_pattern_doc => &Plymio.Codi.Pattern.Doc.cpo_pattern_doc_normalise/1,
    @plymio_codi_pattern_since => &Plymio.Codi.Pattern.Other.cpo_pattern_since_normalise/1,
    @plymio_codi_pattern_deprecated =>
      &Plymio.Codi.Pattern.Other.cpo_pattern_deprecated_normalise/1,
    @plymio_codi_pattern_typespec_spec =>
      &Plymio.Codi.Pattern.Typespec.cpo_pattern_typespec_spec_normalise/1,
    @plymio_codi_pattern_bang => &Plymio.Codi.Pattern.Bang.cpo_pattern_bang_normalise/1,
    @plymio_codi_pattern_bang_module =>
      &Plymio.Codi.Pattern.Bang.cpo_pattern_bang_module_normalise/1,
    @plymio_codi_pattern_query => &Plymio.Codi.Pattern.Query.cpo_pattern_query_normalise/1,
    @plymio_codi_pattern_query_module =>
      &Plymio.Codi.Pattern.Query.cpo_pattern_query_module_normalise/1,
    @plymio_codi_pattern_delegate =>
      &Plymio.Codi.Pattern.Delegate.cpo_pattern_delegate_normalise/1,
    @plymio_codi_pattern_delegate_module =>
      &Plymio.Codi.Pattern.Delegate.cpo_pattern_delegate_module_normalise/1,
    @plymio_codi_pattern_proxy_fetch =>
      &Plymio.Codi.Pattern.Proxy.cpo_pattern_proxy_fetch_normalise/1,
    @plymio_codi_pattern_proxy_put =>
      &Plymio.Codi.Pattern.Proxy.cpo_pattern_proxy_put_normalise/1,
    @plymio_codi_pattern_proxy_get =>
      &Plymio.Codi.Pattern.Proxy.cpo_pattern_proxy_get_normalise/1,
    @plymio_codi_pattern_proxy_delete =>
      &Plymio.Codi.Pattern.Proxy.cpo_pattern_proxy_delete_normalise/1,
    @plymio_codi_pattern_struct_export =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_export_normalise/1,
    @plymio_codi_pattern_struct_update =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_update_normalise/1,
    @plymio_codi_pattern_struct_set =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_set_normalise/1,
    @plymio_codi_pattern_struct_get =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_get_normalise/1,
    @plymio_codi_pattern_struct_get1 =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_get_normalise/1,
    @plymio_codi_pattern_struct_get2 =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_get_normalise/1,
    @plymio_codi_pattern_struct_fetch =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_fetch_normalise/1,
    @plymio_codi_pattern_struct_put =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_put_normalise/1,
    @plymio_codi_pattern_struct_maybe_put =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_maybe_put_normalise/1,
    @plymio_codi_pattern_struct_has? =>
      &Plymio.Codi.Pattern.Struct.cpo_pattern_struct_has_normalise/1
  }

  @plymio_codi_pattern_express_dispatch %{
    @plymio_codi_pattern_form => &Plymio.Codi.Pattern.Other.express_pattern/3,
    @plymio_codi_pattern_doc => &Plymio.Codi.Pattern.Doc.express_pattern/3,
    @plymio_codi_pattern_since => &Plymio.Codi.Pattern.Other.express_pattern/3,
    @plymio_codi_pattern_deprecated => &Plymio.Codi.Pattern.Other.express_pattern/3,
    @plymio_codi_pattern_typespec_spec => &Plymio.Codi.Pattern.Typespec.express_pattern/3,
    @plymio_codi_pattern_bang => &Plymio.Codi.Pattern.Bang.express_pattern/3,
    @plymio_codi_pattern_bang_module => &Plymio.Codi.Pattern.Bang.express_pattern/3,
    @plymio_codi_pattern_query => &Plymio.Codi.Pattern.Query.express_pattern/3,
    @plymio_codi_pattern_query_module => &Plymio.Codi.Pattern.Query.express_pattern/3,
    @plymio_codi_pattern_delegate => &Plymio.Codi.Pattern.Delegate.express_pattern/3,
    @plymio_codi_pattern_delegate_module => &Plymio.Codi.Pattern.Delegate.express_pattern/3,
    @plymio_codi_pattern_proxy_fetch => &Plymio.Codi.Pattern.Proxy.express_pattern/3,
    @plymio_codi_pattern_proxy_put => &Plymio.Codi.Pattern.Proxy.express_pattern/3,
    @plymio_codi_pattern_proxy_get => &Plymio.Codi.Pattern.Proxy.express_pattern/3,
    @plymio_codi_pattern_proxy_delete => &Plymio.Codi.Pattern.Proxy.express_pattern/3,
    @plymio_codi_pattern_struct_update => &Plymio.Codi.Pattern.Struct.express_pattern/3,
    @plymio_codi_pattern_struct_export => &Plymio.Codi.Pattern.Struct.express_pattern/3,
    @plymio_codi_pattern_struct_set => &Plymio.Codi.Pattern.Struct.express_pattern/3,
    @plymio_codi_pattern_struct_get => &Plymio.Codi.Pattern.Struct.express_pattern/3,
    @plymio_codi_pattern_struct_get1 => &Plymio.Codi.Pattern.Struct.express_pattern/3,
    @plymio_codi_pattern_struct_get2 => &Plymio.Codi.Pattern.Struct.express_pattern/3,
    @plymio_codi_pattern_struct_fetch => &Plymio.Codi.Pattern.Struct.express_pattern/3,
    @plymio_codi_pattern_struct_put => &Plymio.Codi.Pattern.Struct.express_pattern/3,
    @plymio_codi_pattern_struct_maybe_put => &Plymio.Codi.Pattern.Struct.express_pattern/3,
    @plymio_codi_pattern_struct_has? => &Plymio.Codi.Pattern.Struct.express_pattern/3
  }

  @plymio_codi_stage_dispatch [
    {@plymio_codi_stage_normalise, &__MODULE__.Stage.Normalise.produce_stage/1},
    {@plymio_codi_stage_commit, &__MODULE__.Stage.Commit.produce_stage/1},
    {@plymio_codi_stage_express, &__MODULE__.Stage.Express.produce_stage/1},
    {@plymio_codi_stage_review, &__MODULE__.Stage.Review.produce_stage/1}
  ]

  @plymio_codi_kvs_verb [
    # struct
    @plymio_codi_field_alias_snippets,
    @plymio_codi_field_alias_stage_dispatch,
    @plymio_codi_field_alias_patterns,
    @plymio_codi_field_alias_pattern_dicts,
    @plymio_codi_field_alias_pattern_normalisers,
    @plymio_codi_field_alias_pattern_express_dispatch,
    @plymio_codi_field_alias_forms,
    @plymio_codi_field_alias_forms_edit,
    @plymio_codi_field_alias_vekil,
    @plymio_codi_field_alias_module_fva_dict,
    @plymio_codi_field_alias_module_doc_dict,

    # virtual
    @plymio_codi_pattern_alias_form,
    @plymio_codi_pattern_alias_doc,
    @plymio_codi_pattern_alias_typespec_spec,
    @plymio_codi_pattern_alias_since,
    @plymio_codi_pattern_alias_deprecated,
    @plymio_codi_pattern_alias_bang,
    @plymio_codi_pattern_alias_bang_module,
    @plymio_codi_pattern_alias_query,
    @plymio_codi_pattern_alias_query_module,
    @plymio_codi_pattern_alias_delegate,
    @plymio_codi_pattern_alias_delegate_module,
    @plymio_codi_pattern_alias_proxy_fetch,
    @plymio_codi_pattern_alias_proxy_put,
    @plymio_codi_pattern_alias_proxy_get,
    @plymio_codi_pattern_alias_proxy_delete,
    @plymio_codi_pattern_alias_struct_export,
    @plymio_codi_pattern_alias_struct_update,
    @plymio_codi_pattern_alias_struct_set,
    @plymio_codi_pattern_alias_struct_get,
    @plymio_codi_pattern_alias_struct_get1,
    @plymio_codi_pattern_alias_struct_get2,
    @plymio_codi_pattern_alias_struct_fetch,
    @plymio_codi_pattern_alias_struct_put,
    @plymio_codi_pattern_alias_struct_maybe_put,
    @plymio_codi_pattern_alias_struct_has?,
    @plymio_codi_key_alias_pattern
  ]

  @plymio_codi_dict_verb @plymio_codi_kvs_verb
                         |> opts_create_aliases_dict

  @plymio_codi_defstruct [
    {@plymio_codi_field_snippets, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_stage_dispatch, @plymio_codi_stage_dispatch},
    {@plymio_codi_field_patterns, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_pattern_express_dispatch, @plymio_codi_pattern_express_dispatch},
    {@plymio_codi_field_pattern_dicts, @plymio_codi_pattern_dicts},
    {@plymio_codi_field_pattern_normalisers, @plymio_codi_pattern_normalisers},
    {@plymio_codi_field_forms, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_forms_edit, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_vekil, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_module_fva_dict, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_module_doc_dict, @plymio_fontais_the_unset_value}
  ]

  defstruct @plymio_codi_defstruct

  @type t :: %__MODULE__{}
  @type kv :: Plymio.Fontais.kv()
  @type opts :: Plymio.Fontais.opts()
  @type error :: Plymio.Fontais.error()
  @type result :: Plymio.Fontais.result()
  @type form :: Plymio.Fontais.form()
  @type forms :: Plymio.Fontais.forms()

  @doc false

  def update_canonical_opts(opts, dict \\ @plymio_codi_dict_verb) do
    opts |> PFO.opts_canonical_keys(dict)
  end

  [
    :state_base_package,
    :state_defp_update_field_header,
    :state_defp_update_proxy_field_normalise
  ]
  |> VEKILUTIL.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_rename_atoms, [proxy_field: @plymio_codi_field_module_fva_dict]},
        {@plymio_fontais_key_rename_funs, [proxy_field_normalise: :validate_module_dict]}
      ]
  )

  defp update_field(%__MODULE__{} = state, {k, v})
       when k == @plymio_codi_field_vekil do
    cond do
      Plymio.Vekil.Utility.vekil?(v) ->
        {:ok, state |> struct!([{@plymio_codi_field_vekil, v}])}

      true ->
        with {:ok, vekil} <- [{@plymio_vekil_field_dict, v}] |> Plymio.Vekil.Form.new() do
          {:ok, state |> struct!([{@plymio_codi_field_vekil, vekil}])}
        else
          {:error, %{__exception__: true}} = result -> result
        end
    end
  end

  defp update_field(%__MODULE__{} = state, {k, v})
       when k in @plymio_codi_pattern_types or k == @plymio_codi_key_pattern do
    state |> add_snippets({k, v})
  end

  defp update_field(%__MODULE__{} = state, {k, v})
       when k == @plymio_codi_field_pattern_express_dispatch do
    with {:ok, dispatch_vector} <- v |> validate_pattern_dispatch_vector do
      state |> struct!([{@plymio_codi_field_pattern_express_dispatch, dispatch_vector}])
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  :state_defp_update_proxy_field_keyword
  |> VEKILUTIL.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_rename_atoms, [proxy_field: @plymio_codi_field_forms_edit]}
      ]
  )

  :state_defp_update_proxy_field_opzioni_validate
  |> VEKILUTIL.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_rename_atoms, [proxy_field: @plymio_codi_field_patterns]}
      ]
  )

  :state_defp_update_proxy_field_passthru
  |> VEKILUTIL.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_rename_atoms, [proxy_field: @plymio_codi_field_snippets]}
      ]
  )

  :state_defp_update_field_unknown
  |> VEKILUTIL.reify_proxies(@codi_opts)

  @plymio_codi_defstruct_updaters @plymio_codi_defstruct

  for {name, _} <- @plymio_codi_defstruct_updaters do
    update_fun = "update_#{name}" |> String.to_atom()

    @doc false
    def unquote(update_fun)(%__MODULE__{} = state, value) do
      state |> update([{unquote(name), value}])
    end
  end

  @plymio_codi_defstruct_reseters @plymio_codi_defstruct
                                  |> Keyword.take([
                                    @plymio_codi_field_snippets,
                                    @plymio_codi_field_patterns
                                  ])

  for {name, _} <- @plymio_codi_defstruct_reseters do
    reset_fun = "reset_#{name}" |> String.to_atom()

    @doc false
    def unquote(reset_fun)(%__MODULE__{} = state, value \\ @plymio_fontais_the_unset_value) do
      state |> update([{unquote(name), value}])
    end
  end

  defp add_snippets(state, patterns)

  defp add_snippets(%__MODULE__{@plymio_codi_field_snippets => snippets} = state, new_snippets) do
    snippets
    |> case do
      x when is_value_unset(x) ->
        state |> update_snippets(List.wrap(new_snippets))

      x when is_list(x) ->
        state |> update_snippets(x ++ List.wrap(new_snippets))
    end
  end

  [
    :doc_false,
    :workflow_def_produce
  ]
  |> VEKILUTIL.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           {:express, ctx, args} -> {:produce_recurse, ctx, args}
           :PRODUCESTAGESTRUCT -> __MODULE__
           x -> x
         end}
      ]
  )

  @doc false

  @since "0.1.0"

  @spec produce_recurse(t) :: {:ok, {opts, t}} | {:error, error}

  def produce_recurse(codi)

  def produce_recurse(%__MODULE__{@plymio_codi_field_snippets => snippets} = state)
      when is_value_set(snippets) do
    with {:ok, {_product, %__MODULE__{} = state}} <-
           state |> __MODULE__.Stage.Normalise.normalise_snippets(),
         {:ok, %__MODULE__{} = state} = state |> reset_snippets,
         {:ok, {_product, %__MODULE__{}}} = result <- state |> produce_recurse do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def produce_recurse(%__MODULE__{} = state) do
    with {:ok, {product, state}} <- state |> produce_stages,
         {:ok, cpos} <- product |> cpo_get_patterns do
      # unless all cpos have status "done" need to recurse. default is done.
      cpos
      |> map_collate0_enum(fn cpo -> cpo |> cpo_get_status(@plymio_codi_status_done) end)
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, statuses} ->
          statuses
          |> Enum.all?(fn status -> status == @plymio_codi_status_done end)
          |> case do
            true ->
              {:ok, {product, state}}

            _ ->
              state |> produce_recurse
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @since "0.1.0"

  @spec produce_codi(any, any) :: {:ok, {forms, t}} | {:error, error}

  def produce_codi(opts, codi_or_opts \\ [])

  def produce_codi(opts, %__MODULE__{} = state) do
    # need to reset patterns to stop infinite recursion
    with {:ok, %__MODULE__{} = state} <- state |> reset_patterns,
         {:ok, %__MODULE__{} = state} <- state |> reset_snippets,
         {:ok, %__MODULE__{} = state} <- state |> update(opts),
         {:ok, {opts_patterns, %__MODULE__{} = state}} <- state |> produce,
         {:ok, opzionis} <- opts_patterns |> cpo_get_patterns,
         {:ok, cpo} <- opzionis |> opzioni_flatten,
         {:ok, cpo} <- cpo |> cpo_put_set_struct_field(state, @plymio_codi_field_forms_edit),
         {:ok, forms} <- cpo |> cpo_edit_forms do
      {:ok, {forms, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def produce_codi(opts, new_opts) do
    with {:ok, %__MODULE__{} = state} <- new_opts |> new,
         {:ok, _} = result <- opts |> produce_codi(state) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defmacro reify_codi(opts \\ [], other_opts \\ []) do
    module = __CALLER__.module

    quote bind_quoted: [opts: opts, other_opts: other_opts, module: module] do
      with {:ok, {forms, _}} <- opts |> Plymio.Codi.produce_codi(other_opts),
           {:ok, forms} <- forms |> Plymio.Fontais.Form.forms_normalise() do
        result =
          try do
            forms
            |> Code.eval_quoted([], __ENV__)
            |> case do
              {_, _} = value ->
                {:ok, value}

              value ->
                {:error,
                 %RuntimeError{message: "Code.eval_quoted failed, got: #{inspect(value)}"}}
            end
          rescue
            error -> {:error, error}
          end

        {:ok,
         [
           {:forms, forms},
           {:module, module},
           {:result, result}
         ]}
      else
        {:error, %{__exception__: true} = error} -> raise error
      end
    end
  end

  [
    :doc_false,
    :workflow_def_produce_stages
  ]
  |> VEKILUTIL.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           :produce_stage_field -> @plymio_codi_field_stage_dispatch
           :PRODUCESTAGESTRUCT -> __MODULE__
           x -> x
         end}
      ]
  )

  defmacro __using__(_opts \\ []) do
    quote do
      require Plymio.Codi, as: CODI
      require Plymio.Fontais.Guard
      use Plymio.Fontais.Attribute
      use Plymio.Codi.Attribute
    end
  end
end

defimpl Inspect, for: Plymio.Codi do
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_value_unset: 1
    ]

  def inspect(
        %Plymio.Codi{
          @plymio_codi_field_vekil => vekil,
          @plymio_codi_field_snippets => snippets,
          @plymio_codi_field_patterns => patterns,
          @plymio_codi_field_forms => forms
        },
        _opts
      ) do
    vekil_telltale =
      vekil
      |> case do
        x when is_value_unset(x) -> nil
        x -> "K=#{inspect(x)}"
      end

    snippets_telltale =
      snippets
      |> case do
        x when is_value_unset(x) -> nil
        x when is_list(x) -> "S=#{x |> length}"
        _ -> "S=?"
      end

    patterns_telltale =
      patterns
      |> case do
        x when is_value_unset(x) ->
          nil

        x when is_list(x) ->
          [
            "P=#{x |> length}/(",
            x
            |> Stream.take(5)
            |> Stream.map(fn opts ->
              opts
              |> Keyword.new()
              |> Keyword.get(@plymio_codi_key_pattern)
              |> to_string
            end)
            |> Enum.join(","),
            ")"
          ]
          |> Enum.join()
      end

    forms_telltale =
      forms
      |> case do
        x when is_value_unset(x) ->
          nil

        x when is_list(x) ->
          "F=#{x |> length}"
      end

    codi_telltale =
      [
        snippets_telltale,
        patterns_telltale,
        forms_telltale,
        vekil_telltale
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join("; ")

    "CODI(#{codi_telltale})"
  end
end
