defmodule Plymio.Codi.Pattern.Proxy do
  @moduledoc false

  alias Plymio.Codi, as: CODI
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
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

  import Plymio.Funcio.Enum.Map.Collate,
    only: [
      map_collate0_enum: 2
    ]

  import Plymio.Codi.Utility,
    only: [
      opts_resolve_proxy_names: 1
    ]

  import Plymio.Fontais.Form,
    only: [
      forms_normalise: 1
    ]

  import Plymio.Fontais.Form,
    only: [
      forms_edit: 2,
      forms_normalise: 1
    ]

  import Plymio.Codi.Utility.GetSet,
    only: [
      cpo_normalise: 2,
      cpo_done_with_form: 2
    ]

  @pattern_proxy_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_proxy_name,
    @plymio_codi_key_alias_transform,
    @plymio_codi_key_alias_postwalk
  ]

  @pattern_proxy_dict_alias @pattern_proxy_kvs_alias
                            |> opts_create_aliases_dict

  def cpo_pattern_proxy_normalise(cpo, dict \\ nil) do
    cpo |> cpo_normalise(dict || @pattern_proxy_dict_alias)
  end

  def opts_dict_canonical_keys() do
    @pattern_proxy_dict_alias
  end

  def express_pattern(codi, pattern, opts)

  def express_pattern(%CODI{@plymio_codi_field_vekil => vekil_dict}, pattern, _cpo)
      when pattern == @plymio_codi_pattern_proxy and is_value_unset_or_nil(vekil_dict) do
    new_error_result(m: "vekil missing")
  end

  def express_pattern(%CODI{@plymio_codi_field_vekil => vekil_dict} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_proxy do
    with {:ok, cpo} <- cpo |> cpo_pattern_proxy_normalise,
         {:ok, proxy_names} <- cpo |> opts_resolve_proxy_names,
         {:ok, forms} <- vekil_dict |> resolve_vekil_proxies(proxy_names),
         {:ok, forms} <- forms |> forms_edit(cpo),
         {:ok, cpo} <- cpo |> cpo_done_with_form(forms) do
      {:ok, {cpo, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def express_pattern(_codi, pattern, opts) do
    new_error_result(m: "proxy pattern #{inspect(pattern)} invalid", v: opts)
  end

  # recurses

  defp resolve_vekil_proxy(vekil_dict, proxy_name, seen_proxies) do
    vekil_dict
    |> Map.fetch(proxy_name)
    |> case do
      {:ok, value} ->
        value
        |> List.wrap()
        |> Enum.reduce_while([], fn
          new_proxy, forms when is_atom(new_proxy) ->
            # seen before i.e. looping?
            seen_proxies
            |> Map.has_key?(new_proxy)
            |> case do
              true ->
                {:halt, new_error_result(m: "proxy seen before", v: new_proxy)}

              _ ->
                seen_proxies = seen_proxies |> Map.put(new_proxy, nil)

                with {:ok, new_forms} <-
                       vekil_dict |> resolve_vekil_proxy(new_proxy, seen_proxies) do
                  {:cont, [new_forms | forms]}
                else
                  {:error, %{__struct__: _}} = result -> {:halt, result}
                end
            end

          # must be a form - will be validated later
          form, forms ->
            {:cont, [form | forms]}
        end)
        |> case do
          {:error, %{__struct__: _}} = result ->
            result

          forms ->
            {:ok, forms |> Enum.reverse()}
        end

      _ ->
        new_error_result(m: "proxy not found", v: proxy_name)
    end
  end

  defp resolve_vekil_proxies(vekil_dict, proxies) do
    proxies
    |> List.wrap()
    |> map_collate0_enum(fn proxy_name ->
      vekil_dict |> resolve_vekil_proxy(proxy_name, %{})
    end)
    |> case do
      {:error, %{__struct__: _}} = result ->
        result

      {:ok, forms} ->
        forms |> forms_normalise
    end
  end
end
