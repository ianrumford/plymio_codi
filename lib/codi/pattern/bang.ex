defmodule Plymio.Codi.Pattern.Bang do
  @moduledoc false

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
      cpo_resolve_bang_doc: 2,
      cpo_resolve_fun_name: 2
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

  def cpo_pattern_bang_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_bang_dict_alias)
  end

  def opts_dict_canonical_keys() do
    @pattern_bang_dict_alias
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

  def cpo_pattern_bang_module_normalise(opts, dict \\ nil) do
    opts |> opts_canonical_keys(dict || @pattern_bang_module_dict_alias)
  end

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_bang do
    with {:ok, cpo} <- cpo |> cpo_pattern_bang_normalise,
         {:ok, bang_module} <- cpo |> cpo_resolve_bang_module,
         {:ok, bang_name} <- cpo |> cpo_resolve_bang_name,
         {:ok, bang_args} <- cpo |> cpo_resolve_bang_args,
         {:ok, bang_doc} <-
           cpo |> cpo_resolve_bang_doc([{@plymio_codi_key_default, @plymio_codi_doc_type_bang}]),
         {:ok, real_name} <-
           cpo
           |> cpo_resolve_fun_name([
             {@plymio_codi_key_default, "#{bang_name}!" |> String.to_atom()}
           ]),
         {:ok, {_, %CODI{} = state}} <-
           state |> state_validate_mfa({bang_module, bang_name, length(bang_args)}),

         # base dependent cpo
         {:ok, depend_cpo} <- cpo |> cpo_mark_status_active,
         {:ok, depend_cpo} <- depend_cpo |> cpo_put_fun_module(bang_module),
         {:ok, depend_cpo} <- depend_cpo |> cpo_put_fun_doc(bang_doc),
         {:ok, depend_cpo} <- depend_cpo |> cpo_put_fun_arity(length(bang_args)),
         # delete the fun_args to stop confusion over type args; fun_arity will be used if needed
         {:ok, depend_cpo} <- depend_cpo |> cpo_drop_fun_args,

         # the dependent doc cpo
         {:ok, depend_doc_cpo} <- depend_cpo |> cpo_put_pattern(@plymio_codi_pattern_doc),
         {:ok, depend_doc_cpo} <- depend_doc_cpo |> cpo_put_fun_name(bang_name),

         # the dependent since cpo
         {:ok, depend_since_cpo} <- depend_cpo |> cpo_put_pattern(@plymio_codi_pattern_since),

         # the dependent type cpo
         {:ok, depend_type_cpo} <-
           depend_cpo |> cpo_put_pattern(@plymio_codi_pattern_typespec_spec),
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
