defmodule Plymio.Codi.Pattern.Typespec.Spec do
  @moduledoc false

  alias Plymio.Codi, as: CODI
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_value_unset: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_take_canonical_keys: 2,
      opts_create_aliases_dict: 1
    ]

  import Plymio.Codi.Utility,
    only: [
      cpo_resolve_type_name: 1,
      cpo_resolve_type_args: 1,
      cpo_resolve_type_result: 1
    ]

  import Plymio.Codi.CPO,
    only: [
      cpo_get_type_result: 1,
      cpo_done_with_edited_form: 2
    ]

  @pattern_type_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_typespec_spec_name,
    @plymio_codi_key_alias_typespec_spec_args,
    @plymio_codi_key_alias_typespec_spec_arity,
    @plymio_codi_key_alias_typespec_spec_result,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_type_dict_alias @pattern_type_kvs_alias
                           |> opts_create_aliases_dict

  def cpo_pattern_type_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_type_dict_alias)
  end

  def opts_dict_canonical_keys() do
    @pattern_type_dict_alias
  end

  def express_pattern(codi, pattern, cpo \\ [])

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_typespec_spec do
    with {:ok, cpo} <- cpo |> cpo_pattern_type_normalise,
         {:ok, type_result} <- cpo |> cpo_get_type_result do
      type_result
      # nothing to do?
      |> is_value_unset
      |> case do
        true ->
          # no type wanted => drop the cpo
          {:ok, {[], state}}

        _ ->
          with {:ok, type_name} <- cpo |> cpo_resolve_type_name,
               {:ok, type_args} <- cpo |> cpo_resolve_type_args,
               {:ok, type_result} <- cpo |> cpo_resolve_type_result do
            form =
              quote do
                @spec unquote(type_name)(unquote_splicing(type_args)) ::
                        unquote_splicing(type_result)
              end

            with {:ok, cpo} <- cpo |> cpo_done_with_edited_form(form) do
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
end
