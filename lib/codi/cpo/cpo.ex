defmodule Plymio.Codi.CPO do
  @moduledoc false

  require Plymio.Fontais.Option.Macro, as: PFOM
  require Plymio.Fontais.Option, as: POU
  require Plymio.Code.Utility.Macro, as: CODIMACRO
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_value_set: 1,
      is_value_unset: 1,
      is_value_unset_or_nil: 1,
      is_filled_list: 1
    ]

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Form,
    only: [
      opts_forms_normalise: 2,
      opts_forms_reduce: 2,
      forms_edit: 2,
      forms_normalise: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_normalise: 1,
      opts_validate: 1,
      opts_get: 3,
      opts_get_values: 3,
      opts_put: 3,
      opts_put_new: 3,
      opts_fetch: 2,
      opts_drop: 2
    ]

  @type error :: Plymio.Codi.error()

  @plymio_codi_cpo_kvs_aliases [
    {@plymio_codi_key_pattern, nil},
    {@plymio_codi_key_status, nil},
    {@plymio_codi_key_form, nil},
    {@plymio_codi_key_state, nil},
    {@plymio_codi_key_since, nil},
    {@plymio_codi_key_deprecated, nil},
    {@plymio_codi_key_fun_module, nil},
    {@plymio_codi_key_fun_name, nil},
    {@plymio_codi_key_fun_args, nil},
    {@plymio_codi_key_fun_sig, nil},
    {@plymio_codi_key_fun_arity, nil},
    {@plymio_codi_key_fun_doc, nil},
    {@plymio_codi_key_fun_default, nil},
    {@plymio_codi_key_fun_key, nil},
    {@plymio_codi_key_bang_module, nil},
    {@plymio_codi_key_bang_name, nil},
    {@plymio_codi_key_bang_doc, nil},
    {@plymio_codi_key_bang_arity, nil},
    {@plymio_codi_key_bang_args, nil},
    {@plymio_codi_key_query_module, nil},
    {@plymio_codi_key_query_name, nil},
    {@plymio_codi_key_query_doc, nil},
    {@plymio_codi_key_query_arity, nil},
    {@plymio_codi_key_query_args, nil},
    {@plymio_codi_key_delegate_module, nil},
    {@plymio_codi_key_delegate_name, nil},
    {@plymio_codi_key_delegate_args, nil},
    {@plymio_codi_key_delegate_arity, nil},
    {@plymio_codi_key_delegate_doc, nil},
    {@plymio_codi_key_proxy_name, nil},
    {@plymio_codi_key_proxy_args, nil},
    {@plymio_codi_key_proxy_default, nil},
    {@plymio_codi_key_typespec_spec_name, nil},
    {@plymio_codi_key_typespec_spec_args, nil},
    {@plymio_codi_key_typespec_spec_arity, nil},
    {@plymio_codi_key_typespec_spec_result, nil},
    {@plymio_codi_key_take, nil},
    {@plymio_codi_key_drop, nil},
    {@plymio_codi_key_filter, nil},
    {@plymio_codi_key_reject, nil},
    {@plymio_codi_key_forms_edit, nil}
  ]

  @plymio_codi_cpo_dict_aliases @plymio_codi_cpo_kvs_aliases
                                |> POU.opts_create_aliases_dict()

  def cpo_canonical_opts(cpo, dict \\ @plymio_codi_cpo_dict_aliases) do
    cpo |> POU.opts_canonical_keys(dict)
  end

  defdelegate cpo_normalise(cpo), to: __MODULE__, as: :cpo_canonical_opts
  defdelegate cpo_normalise(cpo, dict), to: __MODULE__, as: :cpo_canonical_opts

  @plymio_codi_ctrl_kvs_aliases [
    {@plymio_codi_ctrl_key, nil},
    {@plymio_codi_ctrl_fun_module_key, nil},
    {@plymio_codi_ctrl_fun_name_key, nil},
    {@plymio_codi_ctrl_fun_args_key, nil},
    {@plymio_codi_ctrl_fun_arity_key, nil},
    {@plymio_codi_ctrl_fun_arity_value, nil},
    {@plymio_codi_ctrl_fun_doc_key, nil},
    {@plymio_codi_ctrl_fun_default_value, nil},
    {@plymio_codi_ctrl_fun_validate_value, nil},
    {@plymio_codi_ctrl_fun_build_value, nil},
    {@plymio_codi_ctrl_fun_key_length, nil}
  ]

  @plymio_codi_ctrl_dict_aliases @plymio_codi_ctrl_kvs_aliases
                                 |> POU.opts_create_aliases_dict()

  def ctrl_normalise(ctrl, dict \\ @plymio_codi_ctrl_dict_aliases) do
    ctrl |> POU.opts_canonical_keys(dict)
  end

  def cpo_take_normalise(cpo, dict \\ @plymio_codi_cpo_dict_aliases) do
    with {:ok, cpo} <- cpo |> POU.opts_take_canonical_keys(dict) do
      {:ok, cpo |> Keyword.new()}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @plymio_codi_patterns_aliases @plymio_codi_pattern_types
                                |> Enum.map(fn k -> {k, nil} end)

  @plymio_codi_patterns_dict_aliases @plymio_codi_patterns_aliases
                                     |> POU.opts_create_aliases_dict()

  def canonical_cpo_pattern(pattern, dict \\ @plymio_codi_patterns_dict_aliases) do
    pattern |> POU.canonical_key(dict)
  end

  [
    cpo_get_delegate_name: @plymio_codi_key_delegate_name,
    cpo_get_delegate_doc: %{
      key: @plymio_codi_key_delegate_doc,
      default: @plymio_codi_key_delegate
    },
    cpo_get_fun_doc: %{
      key: @plymio_codi_key_fun_doc,
      default: nil
    },
    cpo_get_fun_arity: %{
      key: @plymio_codi_key_fun_arity,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_fun_default: %{
      key: @plymio_codi_key_fun_default,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_typespec_spec_result: %{
      key: @plymio_codi_key_typespec_spec_result,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_bang_module: %{
      key: @plymio_codi_key_bang_module,
      default: nil
    },
    cpo_get_bang_name: %{
      key: @plymio_codi_key_bang_name,
      default: nil
    },
    cpo_get_bang_doc: %{key: @plymio_codi_key_bang_doc, default: @plymio_codi_key_bang},
    cpo_get_typespec_spec_name: %{
      key: @plymio_codi_key_typespec_spec_name,
      default: nil
    },
    cpo_get_patterns: %{
      key: @plymio_codi_field_patterns,
      default: []
    },
    cpo_get_pattern: %{
      key: @plymio_codi_key_pattern,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_status: %{
      key: @plymio_codi_key_status,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_form: %{
      key: @plymio_codi_key_form,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_since: %{
      key: @plymio_codi_key_since,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_deprecated: %{
      key: @plymio_codi_key_deprecated,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_proxy_args: %{
      key: @plymio_codi_key_proxy_args,
      default: []
    },
    cpo_get_proxy_default: %{
      key: @plymio_codi_key_proxy_default,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_state: %{
      key: @plymio_codi_key_state,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_forms_edit: %{
      key: @plymio_codi_key_forms_edit,
      default: []
    }
  ]
  |> PFOM.def_custom_opts_get()

  [
    cpo_get_forms: %{
      key: @plymio_codi_key_form,
      default: []
    }
  ]
  |> PFOM.def_custom_opts_get_values()

  [
    cpo_fetch_patterns: @plymio_codi_field_patterns,
    cpo_fetch_pattern: @plymio_codi_key_pattern,
    cpo_fetch_status: @plymio_codi_key_status,
    cpo_fetch_form: @plymio_codi_key_form,
    cpo_fetch_since: @plymio_codi_key_since,
    cpo_fetch_fun_module: @plymio_codi_key_fun_module,
    cpo_fetch_fun_args: @plymio_codi_key_fun_args,
    cpo_fetch_fun_arity: @plymio_codi_key_fun_arity,
    cpo_fetch_fun_default: @plymio_codi_key_fun_default,
    cpo_fetch_fun_key: @plymio_codi_key_fun_key,
    cpo_fetch_delegate_module: @plymio_codi_key_delegate_module,
    cpo_fetch_bang_module: @plymio_codi_key_bang_module,
    cpo_fetch_typespec_spec_result: @plymio_codi_key_typespec_spec_result
  ]
  |> PFOM.def_custom_opts_fetch()

  [
    cpo_put_patterns: @plymio_codi_field_patterns,
    cpo_put_state: @plymio_codi_key_state,
    cpo_put_pattern: @plymio_codi_key_pattern,
    cpo_put_status: @plymio_codi_key_status,
    cpo_put_fun_module: @plymio_codi_key_fun_module,
    cpo_put_fun_name: @plymio_codi_key_fun_name,
    cpo_put_fun_doc: @plymio_codi_key_fun_doc,
    cpo_put_fun_key: @plymio_codi_key_fun_key,
    cpo_put_fun_args: @plymio_codi_key_fun_args,
    cpo_put_fun_arity: @plymio_codi_key_fun_arity,
    cpo_put_form: @plymio_codi_key_form,
    cpo_put_bang_name: @plymio_codi_key_bang_name,
    cpo_put_bang_arity: @plymio_codi_key_bang_arity,
    cpo_put_query_name: @plymio_codi_key_query_name,
    cpo_put_query_arity: @plymio_codi_key_query_arity,
    cpo_put_delegate_name: @plymio_codi_key_delegate_name,
    cpo_put_delegate_arity: @plymio_codi_key_delegate_arity,
    cpo_put_typespec_spec_name: @plymio_codi_key_typespec_spec_name,
    cpo_put_typespec_spec_args: @plymio_codi_key_typespec_spec_args,
    cpo_put_typespec_spec_arity: @plymio_codi_key_typespec_spec_arity,
    cpo_put_typespec_spec_result: @plymio_codi_key_typespec_spec_result
  ]
  |> PFOM.def_custom_opts_put()

  [
    cpo_maybe_put_fun_name: @plymio_codi_key_fun_name,
    cpo_maybe_put_fun_args: @plymio_codi_key_fun_args,
    cpo_maybe_put_fun_arity: @plymio_codi_key_fun_arity,
    cpo_maybe_put_fun_doc: @plymio_codi_key_fun_doc,
    cpo_maybe_put_typespec_spec_args: @plymio_codi_key_typespec_spec_args,
    cpo_maybe_put_typespec_spec_arity: @plymio_codi_key_typespec_spec_arity,
    ## cpo_maybe_put_type_result: @plymio_codi_key_typespec_spec_result,

    cpo_maybe_put_bang_doc: @plymio_codi_key_bang_doc,
    cpo_maybe_put_delegate_name: @plymio_codi_key_delegate_name,
    cpo_maybe_put_delegate_doc: @plymio_codi_key_delegate_doc,
    cpo_maybe_put_query_doc: @plymio_codi_key_query_doc
  ]
  |> CODIMACRO.def_custom_opts_maybe_put()

  [
    cpo_drop_fun_args: @plymio_codi_key_fun_args,
    cpo_drop_form: @plymio_codi_key_form,
    cpo_drop_typespec_spec_name: @plymio_codi_key_typespec_spec_name,
    cpo_drop_typespec_spec_args: @plymio_codi_key_typespec_spec_args,
    cpo_drop_typespec_spec_result: @plymio_codi_key_typespec_spec_result
  ]
  |> PFOM.def_custom_opts_drop()

  [
    cpo_has_fun_doc?: @plymio_codi_key_fun_doc,
    cpo_has_since?: @plymio_codi_key_since
  ]
  |> PFOM.def_custom_opts_has_key?()

  # These take an opts and get the value of a key that will be used
  # with e.g. opts_get on a cpo.
  # Note the default is usually the same as the key itself.

  [
    ctrl_get_fun_arity_value: %{
      key: @plymio_codi_ctrl_fun_arity_value,
      default: @plymio_fontais_the_unset_value
    },
    ctrl_get_fun_module_key: %{
      key: @plymio_codi_ctrl_fun_module_key,
      default: @plymio_codi_key_fun_module
    },
    ctrl_get_fun_name_key: %{
      key: @plymio_codi_ctrl_fun_name_key,
      default: @plymio_codi_key_fun_name
    },
    ctrl_get_fun_args_key: %{
      key: @plymio_codi_ctrl_fun_args_key,
      default: @plymio_codi_key_fun_args
    },
    ctrl_get_fun_arity_key: %{
      key: @plymio_codi_ctrl_fun_arity_key,
      default: @plymio_codi_key_fun_arity
    },
    ctrl_get_fun_doc_key: %{
      key: @plymio_codi_ctrl_fun_doc_key,
      default: @plymio_codi_key_fun_doc
    },
    ctrl_get_fun_default_value: %{
      key: @plymio_codi_ctrl_fun_default_value,
      default: @plymio_fontais_the_unset_value
    },
    ctrl_get_fun_validate_value: %{
      key: @plymio_codi_ctrl_fun_validate_value,
      default: quote(do: fn v -> v end)
    },
    ctrl_get_fun_build_value: %{
      key: @plymio_codi_ctrl_fun_build_value,
      default: quote(do: fn v -> v end)
    },
    ctrl_get_fun_key_length: %{
      key: @plymio_codi_ctrl_fun_key_length,
      default: @plymio_fontais_the_unset_value
    }
  ]
  |> PFOM.def_custom_opts_get()

  [
    ctrl_fetch_key: @plymio_codi_ctrl_key,
    ctrl_fetch_fun_default_value: @plymio_codi_ctrl_fun_default_value
  ]
  |> PFOM.def_custom_opts_fetch()

  [
    ctrl_put_key: @plymio_codi_ctrl_key,
    ctrl_put_fun_module_key: @plymio_codi_ctrl_fun_module_key,
    ctrl_put_fun_name_key: @plymio_codi_ctrl_fun_name_key,
    ctrl_put_fun_args_key: @plymio_codi_ctrl_fun_args_key,
    ctrl_put_fun_arity_key: @plymio_codi_ctrl_fun_arity_key,
    ctrl_put_fun_arity_value: @plymio_codi_ctrl_fun_arity_value,
    ctrl_put_fun_doc_key: @plymio_codi_ctrl_fun_doc_key,
    ctrl_put_fun_default_value: @plymio_codi_ctrl_fun_default_value,
    ctrl_put_fun_validate_value: @plymio_codi_ctrl_fun_validate_value,
    ctrl_put_fun_build_value: @plymio_codi_ctrl_fun_build_value,
    ctrl_put_fun_key_length: @plymio_codi_ctrl_fun_key_length
  ]
  |> PFOM.def_custom_opts_put()

  [
    ctrl_has_fun_default_value?: @plymio_codi_ctrl_fun_default_value,
    ctrl_has_fun_module_key?: @plymio_codi_ctrl_fun_module_key
  ]
  |> PFOM.def_custom_opts_has_key?()

  def cpo_new(opts \\ [])

  def cpo_new([]) do
    {:ok, []}
  end

  def cpo_new(opts) do
    with {:ok, _cpo} = result <- opts |> cpo_canonical_opts do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_update(cpo, opts \\ [])

  def cpo_update(cpo, opts) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, opts} <- opts |> opts_normalise,
         {:ok, _cpo} = result <- (cpo ++ opts) |> cpo_canonical_opts do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_transform(cpo, opts \\ [])

  def cpo_transform(cpo, fun_transform)
      when is_function(fun_transform, 1) do
    with {:ok, cpo} <- cpo |> cpo_normalise do
      cpo |> fun_transform.()
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_transform(cpo, opts) do
    with {:ok, cpo} <- cpo |> cpo_normalise do
      opts
      |> List.wrap()
      |> Plymio.Funcio.Enum.Reduce.reduce0_enum(cpo, fn
        verb, cpo when is_function(verb, 1) ->
          verb.(cpo)

        verb, cpo when is_atom(verb) ->
          apply(__MODULE__, verb, [cpo])

        {verb, args}, cpo when is_atom(verb) ->
          apply(__MODULE__, verb, [cpo | List.wrap(args)])

        {verb, args}, cpo when is_function(verb) ->
          apply(verb, [cpo | List.wrap(args)])

        x, _cpo ->
          new_error_result(m: "cpo transform invalid", v: x)
      end)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_maybe_transform(cpo, predicate, opts \\ [])

  def cpo_maybe_transform(cpo, predicate, fun_transform)
      when is_function(fun_transform, 1) do
    with {:ok, cpo} <- cpo |> cpo_normalise,
         {:ok, fun_pred} <- predicate |> normalise_predicate0_fun1 do
      cpo
      |> fun_pred.()
      |> case do
        true ->
          cpo |> fun_transform.()

        _ ->
          {:ok, cpo}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_maybe_transform(cpo, predicate, opts)
      when is_list(opts) do
    with {:ok, cpo} <- cpo |> cpo_normalise,
         {:ok, fun_pred} <- predicate |> normalise_predicate0_fun1 do
      cpo
      |> fun_pred.()
      |> case do
        true ->
          cpo |> cpo_transform(opts)

        _ ->
          {:ok, cpo}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_pipeline_transform(cpo, pipeline \\ [])

  def cpo_pipeline_transform(cpo, pipeline) do
    with {:ok, cpo} <- cpo |> cpo_normalise,
         {:ok, pipeline} <- pipeline |> normalise_cpo_transform_pipeline do
      pipeline
      |> Plymio.Funcio.Enum.Reduce.reduce0_enum(
        cpo,
        fn {fun_pred, fun_transform}, cpo ->
          cpo
          |> fun_pred.()
          |> case do
            true ->
              cpo |> fun_transform.()

            _ ->
              {:ok, cpo}
          end
        end
      )
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def normalise_cpo_transform_pipeline(transform_args)

  def normalise_cpo_transform_pipeline(transform_args) do
    transform_args
    |> List.wrap()
    |> Plymio.Funcio.Enum.Map.Collate.map_collate0_enum(fn
      {predicate, transforms} ->
        with {:ok, fun_pred} <- predicate |> normalise_predicate0_fun1 do
          fun_transform = fn cpo -> cpo |> cpo_transform(transforms) end
          {:ok, {fun_pred, fun_transform}}
        else
          {:error, %{__exception__: true}} = result -> result
        end

      transforms ->
        fun_transform = fn cpo -> cpo |> cpo_transform(transforms) end
        {:ok, {fn _ -> true end, fun_transform}}
    end)
  end

  def cpo_edit_forms(cpo) do
    with {:ok, forms} <- cpo |> cpo_get_forms,
         {:ok, _forms} = result <- cpo |> cpo_edit_forms(forms) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_edit_forms(cpo, forms) when is_value_set(forms) do
    cpo
    |> cpo_get_forms_edit
    |> case do
      {:ok, []} -> forms |> forms_normalise
      {:ok, edits} -> forms |> forms_edit(edits)
    end
    |> case do
      {:error, %{__struct__: _}} = result -> result
      {:ok, _forms} = result -> result
    end
  end

  def cpo_edit_forms(_cpo, forms) when is_value_unset(forms) do
    {:ok, forms}
  end

  def cpo_done_with_form(cpo) do
    cpo |> cpo_mark_status_done
  end

  def cpo_done_with_form(cpo, form) do
    with {:ok, cpo} <- cpo |> cpo_put_form(form),
         {:ok, _cpo} = result <- cpo |> cpo_mark_status_done do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_done_with_edited_form(cpo, form) do
    with {:ok, forms} <- cpo |> cpo_edit_forms(form),
         {:ok, _cpo} = result <- cpo |> cpo_done_with_form(forms) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_maybe_put_typespec_spec_result(cpo, result)

  def cpo_maybe_put_typespec_spec_result(cpo, new_result) do
    with {:ok, result} <- cpo |> cpo_get_typespec_spec_result do
      cond do
        is_value_unset(result) ->
          cpo |> cpo_put_typespec_spec_result(new_result)

        # typespec result = true is "marker" that @spec wanted
        # but expected to use standard result (e.g. :struct_result)
        result === true ->
          cpo |> cpo_put_typespec_spec_result(new_result)

        true ->
          {:ok, cpo}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_maybe_put_status(cpo, status)

  def cpo_maybe_put_status(cpo, new_status)
      when new_status in @plymio_codi_statuses do
    with {:ok, status} <- cpo |> cpo_get_status do
      status
      |> is_value_unset_or_nil
      |> case do
        true -> cpo |> cpo_put_status(new_status)
        _ -> {:ok, cpo}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_maybe_put_status(_cpo, status) do
    new_error_result(m: "pattern status invalid", v: status)
  end

  def cpo_mark_status_done(cpo) do
    with {:ok, cpo} <- cpo |> cpo_put_status(@plymio_codi_status_done),
         {:ok, _} = result <- cpo |> cpo_tidy do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_mark_status_active(cpo) do
    with {:ok, cpo} <- cpo |> cpo_put_status(@plymio_codi_status_active),
         {:ok, _} = result <- cpo |> cpo_tidy do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_mark_status_dormant(cpo) do
    with {:ok, cpo} <- cpo |> cpo_put_status(@plymio_codi_status_dormant),
         {:ok, _} = result <- cpo |> cpo_tidy do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_active?(cpo) do
    with {:ok, status} <- cpo |> cpo_get_status do
      @plymio_codi_status_active == status
    else
      {:error, %{__struct__: _} = error} -> raise error
    end
  end

  def cpo_done?(cpo) do
    with {:ok, status} <- cpo |> cpo_get_status do
      @plymio_codi_status_done == status
    else
      {:error, %{__struct__: _} = error} -> raise error
    end
  end

  # form field is populated?  (note nil is a valid form)
  def cpo_form?(cpo) do
    with {:ok, form} <- cpo |> cpo_get_form do
      is_value_unset(form)
    else
      {:error, %{__struct__: _} = error} -> raise error
    end
  end

  # delete dup keys, sort keys
  def cpo_tidy(cpo) do
    with {:ok, cpo} <- cpo |> cpo_normalise do
      {:ok, cpo |> Keyword.new() |> Enum.sort_by(fn {k, _v} -> k end) |> Enum.reverse()}
    else
      {:error, %{__struct__: _} = error} -> raise error
    end
  end

  # vacant => done and no form

  def cpo_done_no_form?(cpo) do
    cpo
    |> cpo_done?
    |> case do
      true -> cpo |> cpo_form?
      _ -> false
    end
  end

  def cpo_get_typespec_spec_opts(cpo) do
    with {:ok, cpo} <- cpo |> cpo_normalise do
      {:ok, cpo |> Keyword.take(@plymio_codi_keys_typespec_spec)}
    else
      {:error, %{__struct__: _} = error} -> raise error
    end
  end

  def cpo_has_typespec_spec_opts?(cpo) do
    with {:ok, cpo} <- cpo |> cpo_normalise,
         {:ok, typespec_spec_opts} <- cpo |> cpo_get_typespec_spec_opts do
      typespec_spec_opts |> is_filled_list
    else
      {:error, %{__struct__: _} = error} -> raise error
    end
  end

  def cpo_maybe_add_typespec_spec_opts(cpo, opts \\ []) do
    with {:ok, cpo} <- cpo |> cpo_normalise,
         {:ok, typespec_spec_opts} <- cpo |> cpo_get_typespec_spec_opts do
      typespec_spec_opts
      |> is_filled_list
      |> case do
        true ->
          with {:ok, typespec_spec_cpo} <- opts |> cpo_normalise do
            {:ok, cpo ++ typespec_spec_cpo}
          else
            {:error, %{__exception__: true}} = result -> result
          end

        _ ->
          {:ok, cpo}
      end
    else
      {:error, %{__struct__: _} = error} -> raise error
    end
  end

  def cpo_normalise_forms(cpo \\ [])

  def cpo_normalise_forms(cpo) do
    cpo |> opts_forms_normalise(@plymio_codi_key_form)
  end

  def cpo_reduce_forms(cpo \\ [])

  def cpo_reduce_forms(cpo) do
    cpo |> opts_forms_reduce(@plymio_codi_key_form)
  end

  def cpo_put_set_struct_field(cpo, %{__struct__: _} = state, field) do
    with {:ok, field} <- field |> Plymio.Fontais.Utility.validate_key(),
         {:ok, cpo} <- cpo |> cpo_normalise do
      state
      |> Map.get(field, @plymio_fontais_the_unset_value)
      |> case do
        x when is_value_set(x) -> cpo |> opts_put(field, x)
        _ -> {:ok, cpo}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def normalise_predicate0_fun1(predicate)

  def normalise_predicate0_fun1(predicate)
      when is_function(predicate, 1) do
    fun = fn value ->
      value
      |> predicate.()
      |> case do
        x when x in [nil, false] -> false
        x when x in [true] -> true
        {:ok, _} -> true
        {:error, _} -> false
        _ -> false
      end
    end

    {:ok, fun}
  end

  def normalise_predicate0_fun1(predicate) do
    new_error_result(m: "predicate invalid", v: predicate)
  end
end
