defmodule Plymio.Codi.Pattern.Doc do
  @moduledoc false

  alias Plymio.Codi, as: CODI
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

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
      opts_create_aliases_dict: 1,
      # opts_maybe_canonical_keys: 2,
      opts_take_canonical_keys: 2
    ]

  import Plymio.Codi.Utility,
    only: [
      cpo_resolve_fun_module: 1,
      cpo_resolve_fun_name: 1,
      cpo_resolve_fun_arity: 1
    ]

  import Plymio.Codi.CPO

  @pattern_doc_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_form,
    @plymio_codi_key_alias_fun_doc,
    @plymio_codi_key_alias_fun_module,
    @plymio_codi_key_alias_fun_name,
    @plymio_codi_key_alias_fun_args,
    @plymio_codi_key_alias_fun_arity,
    @plymio_codi_key_alias_delegate_name,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_doc_dict_alias @pattern_doc_kvs_alias
                          |> opts_create_aliases_dict

  def cpo_pattern_doc_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_doc_dict_alias)
  end

  def opts_dict_canonical_keys() do
    @pattern_doc_dict_alias
  end

  defp express_doc_pattern(codi, pattern, opts)

  defp express_doc_pattern(%CODI{} = state, pattern, _opts)
       when is_value_unset_or_nil(pattern) do
    {:ok, {@plymio_fontais_the_unset_value, state}}
  end

  defp express_doc_pattern(%CODI{} = state, pattern, _opts)
       when is_binary(pattern) do
    {:ok, {quote(do: @doc(unquote(pattern))), state}}
  end

  defp express_doc_pattern(%CODI{} = state, pattern, _opts)
       when pattern == false do
    {:ok, {quote(do: @doc(false)), state}}
  end

  defp express_doc_pattern(%CODI{} = state, pattern, opts)
       when pattern == @plymio_codi_doc_type_bang do
    with {:ok, fun_name} <- opts |> cpo_resolve_fun_name,
         {:ok, fun_module} <- opts |> cpo_resolve_fun_module,
         {:ok, fun_arity} <- opts |> cpo_resolve_fun_arity do
      docstring =
        fun_module
        |> case do
          x when is_value_unset_or_nil(x) ->
            "Bang function for `#{to_string(fun_name)}/#{fun_arity}`"

          x ->
            "Bang function for `#{inspect(x)}.#{to_string(fun_name)}/#{fun_arity}`"
        end

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, opts)
       when pattern == @plymio_codi_doc_type_delegate do
    with {:ok, fun_module} <- opts |> cpo_resolve_fun_module,
         {:ok, fun_name} <- opts |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- opts |> cpo_resolve_fun_arity do
      docstring =
        fun_module
        |> case do
          x when is_value_unset_or_nil(x) ->
            "Delegated to `#{fun_name}/#{fun_arity}`"

          x ->
            "Delegated to `#{inspect(x)}.#{fun_name}/#{fun_arity}`"
        end

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, opts)
       when is_function(pattern, 2) do
    pattern.(state, opts)
    |> case do
      {:error, %{__exception__: true}} = result -> result
      {:ok, _} = result -> result
      value -> {:ok, value}
    end
    |> case do
      {:error, %{__exception__: true}} = result ->
        result

      {:ok, value} ->
        value
        |> case do
          x when is_binary(x) -> {:ok, x}
          x -> {:ok, x |> inspect}
        end
    end
  end

  defp express_doc_pattern(_codi, pattern, opts) do
    new_error_result(m: "doc pattern #{inspect(pattern)} invalid", v: opts)
  end

  def express_pattern(codi, pattern, opts \\ [])

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_doc do
    with {:ok, cpo} <- cpo |> cpo_pattern_doc_normalise,
         {:ok, fun_doc} <- cpo |> cpo_get_fun_doc,
         {:ok, {form, %CODI{} = state}} <- state |> express_doc_pattern(fun_doc, cpo) do
      with {:ok, cpo} <- cpo |> cpo_done_with_edited_form(form) do
        {:ok, {cpo, state}}
      else
        {:error, %{__exception__: true}} = result -> result
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
