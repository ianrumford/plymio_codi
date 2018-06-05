defmodule Plymio.Codi.CPO do
  @moduledoc false

  require Plymio.Fontais.Option.Macro, as: PFOM
  require Plymio.Fontais.Option, as: POU
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  # cpo = codi pattern opts

  import Plymio.Fontais.Guard,
    only: [
      is_value_set: 1,
      is_value_unset: 1,
      is_value_unset_or_nil: 1
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
    {@plymio_codi_key_fun_module, nil},
    {@plymio_codi_key_fun_name, nil},
    {@plymio_codi_key_fun_args, nil},
    {@plymio_codi_key_fun_sig, nil},
    {@plymio_codi_key_fun_arity, nil},
    {@plymio_codi_key_fun_doc, nil},
    {@plymio_codi_key_fun_default, nil},
    {@plymio_codi_key_bang_module, nil},
    {@plymio_codi_key_bang_name, nil},
    {@plymio_codi_key_bang_doc, nil},
    {@plymio_codi_key_bang_arity, nil},
    {@plymio_codi_key_bang_args, nil},
    {@plymio_codi_key_delegate_module, nil},
    {@plymio_codi_key_delegate_name, nil},
    {@plymio_codi_key_delegate_args, nil},
    {@plymio_codi_key_delegate_arity, nil},
    {@plymio_codi_key_delegate_doc, nil},
    {@plymio_codi_key_proxy_name, nil},
    {@plymio_codi_key_proxy_args, nil},
    {@plymio_codi_key_typespec_spec_name, nil},
    {@plymio_codi_key_typespec_spec_args, nil},
    {@plymio_codi_key_typespec_spec_arity, nil},
    {@plymio_codi_key_typespec_spec_result, nil},
    {@plymio_codi_key_take, nil},
    {@plymio_codi_key_drop, nil},
    {@plymio_codi_key_filter, nil},
    {@plymio_codi_key_reject, nil},
    {@plymio_codi_key_forms_edit, nil},
    {@plymio_codi_key_default, nil}
  ]

  @plymio_codi_cpo_dict_aliases @plymio_codi_cpo_kvs_aliases
                                |> POU.opts_create_aliases_dict()

  def cpo_canonical_opts(cpo, dict \\ @plymio_codi_cpo_dict_aliases) do
    cpo |> POU.opts_canonical_keys(dict)
  end

  defdelegate cpo_normalise(cpo), to: __MODULE__, as: :cpo_canonical_opts
  defdelegate cpo_normalise(cpo, dict), to: __MODULE__, as: :cpo_canonical_opts

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
    cpo_get_type_result: %{
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
    cpo_get_type_name: %{
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
    cpo_get_default: %{
      key: @plymio_codi_key_default,
      default: @plymio_fontais_the_unset_value
    },
    cpo_get_proxy_args: %{
      key: @plymio_codi_key_proxy_args,
      default: []
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
    cpo_fetch_delegate_module: @plymio_codi_key_delegate_module,
    cpo_fetch_bang_module: @plymio_codi_key_bang_module
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
    cpo_put_fun_args: @plymio_codi_key_fun_args,
    cpo_put_fun_arity: @plymio_codi_key_fun_arity,
    cpo_put_form: @plymio_codi_key_form,
    cpo_put_bang_name: @plymio_codi_key_bang_name,
    cpo_put_bang_arity: @plymio_codi_key_bang_arity,
    cpo_put_delegate_name: @plymio_codi_key_delegate_name,
    cpo_put_delegate_arity: @plymio_codi_key_delegate_arity,
    cpo_put_type_arity: @plymio_codi_key_typespec_spec_arity
  ]
  |> PFOM.def_custom_opts_put()

  [
    cpo_drop_fun_args: @plymio_codi_key_fun_args
  ]
  |> PFOM.def_custom_opts_drop()

  # These take an opts and get the value of a key that will be used
  # with e.g. opts_get on a cpo.
  # Note the default is usually the same as the key itself.

  [
    ctrl_get_key_fun_module: %{
      key: @plymio_codi_key_fun_module,
      default: @plymio_codi_key_fun_module
    },
    ctrl_get_key_fun_name: %{
      key: @plymio_codi_key_fun_name,
      default: @plymio_codi_key_fun_name
    },
    ctrl_get_key_fun_args: %{
      key: @plymio_codi_key_fun_args,
      default: @plymio_codi_key_fun_args
    },
    ctrl_get_key_fun_arity: %{
      key: @plymio_codi_key_fun_arity,
      default: @plymio_codi_key_fun_arity
    },
    ctrl_get_key_fun_doc: %{
      key: @plymio_codi_key_fun_doc,
      default: @plymio_codi_key_fun_doc
    },
    ctrl_get_default: %{
      key: @plymio_codi_key_default,
      default: nil
    },
    ctrl_get_validate_fun: %{
      key: @plymio_codi_key_validate_fun,
      default: quote(do: fn v -> v end)
    }
  ]
  |> PFOM.def_custom_opts_get()

  [
    ctrl_fetch_key: @plymio_codi_key_key
  ]
  |> PFOM.def_custom_opts_fetch()

  [
    ctrl_put_key: @plymio_codi_key_key,
    ctrl_put_default: @plymio_codi_key_default,
    ctrl_put_validate_fun: @plymio_codi_key_validate_fun
  ]
  |> PFOM.def_custom_opts_put()

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
end
