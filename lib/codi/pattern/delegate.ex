defmodule Plymio.Codi.Pattern.Delegate do
  @moduledoc false

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
      cpo_resolve_delegate_name: 2,
      cpo_resolve_delegate_doc: 2,
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

  import Plymio.Codi.Utility.GetSet

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
    @plymio_codi_key_alias_typespec_spec_result
  ]

  @pattern_delegate_dict_alias @pattern_delegate_kvs_alias
                               |> opts_create_aliases_dict

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
    {@plymio_codi_key_reject, nil}
  ]

  @pattern_delegate_module_dict_alias @pattern_delegate_module_kvs_alias
                                      |> opts_create_aliases_dict

  def cpo_pattern_delegate_module_normalise(opts, dict \\ nil) do
    opts |> opts_canonical_keys(dict || @pattern_delegate_module_dict_alias)
  end

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_delegate do
    with {:ok, cpo} <- cpo |> cpo_pattern_delegate_normalise,
         {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, delegate_module} <- cpo |> cpo_resolve_delegate_module,
         {:ok, delegate_name} <-
           cpo |> cpo_resolve_delegate_name([{@plymio_codi_key_default, fun_name}]),
         {:ok, delegate_args} <- cpo |> cpo_resolve_delegate_args,
         {:ok, delegate_doc} <-
           cpo
           |> cpo_resolve_delegate_doc([
             {@plymio_codi_key_default, @plymio_codi_doc_type_delegate}
           ]),
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
         {:ok, depend_type_cpo} <- depend_type_cpo |> cpo_put_type_arity(delegate_args |> length),
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
           {:ok, cpo} <- cpo |> cpo_done_with_form(pattern_form) do
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
