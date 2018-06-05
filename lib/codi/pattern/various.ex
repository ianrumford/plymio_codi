defmodule Plymio.Codi.Pattern.Various do
  @moduledoc false

  alias Plymio.Codi, as: CODI
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_value_unset: 1
    ]

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_take_canonical_keys: 2,
      opts_create_aliases_dict: 1
    ]

  import Plymio.Codi.Utility,
    only: [
      validate_since: 1
    ]

  import Plymio.Codi.CPO,
    only: [
      cpo_fetch_form: 1,
      cpo_get_since: 1,
      cpo_done_with_edited_form: 2
    ]

  @pattern_form_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_form_dict_alias @pattern_form_kvs_alias
                           |> opts_create_aliases_dict

  def cpo_pattern_form_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_form_dict_alias)
  end

  @pattern_since_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_since,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_since_dict_alias @pattern_since_kvs_alias
                            |> opts_create_aliases_dict

  def cpo_pattern_since_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_since_dict_alias)
  end

  def express_pattern(codi, pattern, opts)

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_form do
    with {:ok, cpo} <- cpo |> cpo_pattern_form_normalise,
         {:ok, form} <- cpo |> cpo_fetch_form,
         {:ok, cpo} <- cpo |> cpo_done_with_edited_form(form) do
      {:ok, {cpo, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_since do
    with {:ok, since} <- cpo |> cpo_get_since do
      since
      |> is_value_unset
      |> case do
        true ->
          # drop the pattern
          {:ok, {[], state}}

        _ ->
          with {:ok, since} <- since |> validate_since do
            pattern_form =
              quote do
                @since unquote(since)
              end

            with {:ok, cpo} <- cpo |> cpo_done_with_edited_form(pattern_form) do
              {:ok, {cpo, state}}
            else
              {:error, %{__exception__: true}} = result -> result
            end
          else
            {:error, %{__exception__: true}} = result -> result
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def express_pattern(_codi, pattern, opts) do
    new_error_result(m: "proxy pattern #{inspect(pattern)} invalid", v: opts)
  end
end
