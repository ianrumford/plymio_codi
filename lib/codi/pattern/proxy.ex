defmodule Plymio.Codi.Pattern.Proxy do
  @moduledoc false

  alias Plymio.Codi, as: CODI
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_value_set: 1,
      is_value_unset_or_nil: 1
    ]

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_create_aliases_dict: 1
    ]

  import Plymio.Codi.Utility,
    only: [
      opts_resolve_proxy_names: 1
    ]

  import Plymio.Fontais.Form,
    only: [
      forms_edit: 2
    ]

  import Plymio.Codi.CPO,
    only: [
      cpo_normalise: 2,
      cpo_done_with_edited_form: 2,
      cpo_get_proxy_args: 1,
      cpo_get_default: 1
    ]

  @pattern_proxy_fetch_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_state,
    @plymio_codi_key_alias_proxy_name,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_proxy_fetch_dict_alias @pattern_proxy_fetch_kvs_alias
                                  |> opts_create_aliases_dict

  def cpo_pattern_proxy_fetch_normalise(cpo, dict \\ nil) do
    cpo |> cpo_normalise(dict || @pattern_proxy_fetch_dict_alias)
  end

  @pattern_proxy_put_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_proxy_args
  ]

  @pattern_proxy_put_dict_alias @pattern_proxy_put_kvs_alias
                                |> opts_create_aliases_dict

  def cpo_pattern_proxy_put_normalise(cpo, dict \\ nil) do
    cpo |> cpo_normalise(dict || @pattern_proxy_put_dict_alias)
  end

  @pattern_proxy_delete_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_proxy_name
  ]

  @pattern_proxy_delete_dict_alias @pattern_proxy_delete_kvs_alias
                                   |> opts_create_aliases_dict

  def cpo_pattern_proxy_delete_normalise(cpo, dict \\ nil) do
    cpo |> cpo_normalise(dict || @pattern_proxy_delete_dict_alias)
  end

  @pattern_proxy_get_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_proxy_name,
    @plymio_codi_key_alias_default,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_proxy_get_dict_alias @pattern_proxy_get_kvs_alias
                                |> opts_create_aliases_dict

  def cpo_pattern_proxy_get_normalise(cpo, dict \\ nil) do
    cpo |> cpo_normalise(dict || @pattern_proxy_get_dict_alias)
  end

  def express_pattern(codi, pattern, opts)

  def express_pattern(%CODI{@plymio_codi_field_vekil => vekil}, pattern, _cpo)
      when pattern == @plymio_codi_pattern_proxy_fetch and is_value_unset_or_nil(vekil) do
    new_error_result(m: "vekil missing")
  end

  def express_pattern(%CODI{@plymio_codi_field_vekil => vekil} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_proxy_fetch do
    with {:ok, cpo} <- cpo |> cpo_pattern_proxy_fetch_normalise,
         {:ok, proxy_names} <- cpo |> opts_resolve_proxy_names,
         {:ok, forms} <- vekil |> realise_proxy_fetch_forom(proxy_names),
         {:ok, forms} <- forms |> forms_edit(cpo),
         {:ok, cpo} <- cpo |> cpo_done_with_edited_form(forms) do
      {:ok, {cpo, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def express_pattern(%CODI{@plymio_codi_field_vekil => vekil} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_proxy_put and is_value_unset_or_nil(vekil) do
    with {:ok, %Plymio.Vekil.Form{} = vekil} <- Plymio.Vekil.Form.new(),
         {:ok, %CODI{} = state} <- state |> CODI.update_vekil(vekil),
         {:ok, _} = result <- state |> express_pattern(pattern, cpo) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def express_pattern(%CODI{@plymio_codi_field_vekil => vekil} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_proxy_put do
    with {:ok, cpo} <- cpo |> cpo_pattern_proxy_put_normalise,
         {:ok, proxy_args} <- cpo |> cpo_get_proxy_args,
         {:ok, vekil} <- vekil |> Plymio.Vekil.proxy_put(proxy_args),
         {:ok, %CODI{} = state} <- state |> CODI.update_vekil(vekil) do
      {:ok, {[], state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def express_pattern(%CODI{@plymio_codi_field_vekil => vekil} = state, pattern, _cpo)
      when pattern == @plymio_codi_pattern_proxy_delete and is_value_unset_or_nil(vekil) do
    {:ok, {[], state}}
  end

  def express_pattern(%CODI{@plymio_codi_field_vekil => vekil} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_proxy_delete do
    with {:ok, cpo} <- cpo |> cpo_pattern_proxy_delete_normalise,
         {:ok, proxy_names} <- cpo |> opts_resolve_proxy_names,
         {:ok, vekil} <- vekil |> Plymio.Vekil.proxy_delete(proxy_names),
         {:ok, %CODI{} = state} <- state |> CODI.update_vekil(vekil) do
      {:ok, {[], state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def express_pattern(%CODI{@plymio_codi_field_vekil => vekil} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_proxy_get do
    with {:ok, cpo} <- cpo |> cpo_pattern_proxy_get_normalise,
         {:ok, proxy_names} <- cpo |> opts_resolve_proxy_names,
         {:ok, default} <- cpo |> cpo_get_default,
         {:ok, forms} <- vekil |> realise_proxy_get_forom(proxy_names, default),
         {:ok, forms} <- forms |> forms_edit(cpo),
         {:ok, cpo} <- cpo |> cpo_done_with_edited_form(forms) do
      {:ok, {cpo, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def express_pattern(_codi, pattern, opts) do
    new_error_result(m: "proxy pattern #{inspect(pattern)} invalid", v: opts)
  end

  defp resolve_forom(vekil, forom)

  defp resolve_forom(state, forom) do
    cond do
      Plymio.Vekil.Utility.forom?(forom) ->
        {:ok, {forom, state}}

      Plymio.Vekil.Utility.vekil?(state) ->
        state |> Plymio.Vekil.forom_normalise(forom)

      # default is a form forom
      true ->
        with {:ok, forom} <- forom |> Plymio.Vekil.Forom.Form.normalise() do
          {:ok, {forom, state}}
        else
          {:error, %{__exception__: true}} = result -> result
        end
    end
  end

  defp realise_proxy_fetch_forom(state, proxies) do
    with {:ok, state} <- state |> Plymio.Vekil.Utility.validate_vekil(),
         {:ok, {forom, _}} <- state |> Plymio.Vekil.proxy_fetch(proxies),
         {:ok, {forms, _}} <- forom |> Plymio.Vekil.Forom.realise() do
      {:ok, forms}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp realise_proxy_get_forom(vekil, proxies, default)

  defp realise_proxy_get_forom(state, proxies, default) when is_value_set(state) do
    with {:ok, state} <- state |> Plymio.Vekil.Utility.validate_vekil(),
         {:ok, {forom, _}} <- state |> Plymio.Vekil.proxy_get(proxies, default),
         {:ok, {forms, _}} <- forom |> Plymio.Vekil.Forom.realise() do
      {:ok, forms}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp realise_proxy_get_forom(state, proxies, default) when is_value_unset_or_nil(state) do
    default
    |> is_value_set
    |> case do
      true ->
        with {:ok, {forom, _}} <- state |> resolve_forom(default) do
          # need to return as many forom as proxies but as a list forom
          defaults = List.duplicate(forom, proxies |> List.wrap() |> length)

          with {:ok, forom} <- defaults |> Plymio.Vekil.Utility.forom_reduce(),
               {:ok, {forms, _}} <- forom |> Plymio.Vekil.Forom.realise() do
            {:ok, forms}
          else
            {:error, %{__exception__: true}} = result -> result
          end
        else
          {:error, %{__exception__: true}} = result -> result
        end

      # no vekil and no default => return no forms
      _ ->
        {:ok, []}
    end
  end
end
