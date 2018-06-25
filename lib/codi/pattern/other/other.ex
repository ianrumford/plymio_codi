defmodule Plymio.Codi.Pattern.Other do
  @moduledoc ~S"""
  This module collects the *other*, simple patterns.

  See `Plymio.Codi` for an overview and documentation terms.

  ## Pattern: *form*

  The *form* pattern is a convenience to embed arbitrary code.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:form` | *:forms, :ast, :asts* |

  ## Examples

  A simple example with four functions:

      iex> {:ok, {forms, _}} = [
      ...>    form: quote(do: def(add_1(x), do: x + 1)),
      ...>    ast: quote(do: def(sqr_x(x), do: x * x)),
      ...>    forms: [
      ...>       quote(do: def(sub_1(x), do: x - 1)),
      ...>       quote(do: def(sub_2(x), do: x - 2)),
      ...>      ]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_1(x)) do\n x + 1\n end",
       "def(sqr_x(x)) do\n x * x\n end",
       "def(sub_1(x)) do\n x - 1\n end",
       "def(sub_2(x)) do\n x - 2\n end"]

  Here the subtraction functions are renamed:

      iex> {:ok, {forms, _}} = [
      ...>    form: quote(do: def(add_1(x), do: x + 1)),
      ...>    ast: quote(do: def(sqr_x(x), do: x * x)),
      ...>    forms: [
      ...>      forms: [quote(do: def(sub_1(x), do: x - 1)),
      ...>             quote(do: def(sub_2(x), do: x - 2))],
      ...>      forms_edit: [rename_funs: [sub_1: :decr_1, sub_2: :take_away_2]]]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_1(x)) do\n x + 1\n end",
       "def(sqr_x(x)) do\n x * x\n end",
       "def(decr_1(x)) do\n x - 1\n end",
       "def(take_away_2(x)) do\n x - 2\n end"]

  In this example the edits are "global" and applied to *all* produced forms:

      iex> forms_edit = [rename_funs: [
      ...>  sub_1: :decr_1,
      ...>  sub_2: :take_away_2,
      ...>  add_1: :incr_1,
      ...>  sqr_x: :power_2]
      ...> ]
      ...> {:ok, {forms, _}} = [
      ...>    form: quote(do: def(add_1(x), do: x + 1)),
      ...>    ast: quote(do: def(sqr_x(x), do: x * x)),
      ...>    forms: [quote(do: def(sub_1(x), do: x - 1)),
      ...>            quote(do: def(sub_2(x), do: x - 2))],
      ...> ] |> produce_codi(forms_edit: forms_edit)
      ...> forms |> harnais_helper_show_forms!
      ["def(incr_1(x)) do\n x + 1\n end",
       "def(power_2(x)) do\n x * x\n end",
       "def(decr_1(x)) do\n x - 1\n end",
       "def(take_away_2(x)) do\n x - 2\n end"]

  ## Pattern: *since*

  The *since* pattern builds a `@since` module attribute form.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:since` | |

  ## Examples

  The value must be a string and is validated by `Version.parse/1`:

      iex> {:ok, {forms, _}} = [
      ...>   since: "1.7.9"
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@since(\"1.7.9\")"]

      iex> {:error, error} = [
      ...>   since: "1.2.3.4.5"
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "since invalid, got: 1.2.3.4.5"

  ## Pattern: *deprecated*

  The *deprecated* pattern builds a `@deprecated` module attribute form.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:deprecated` | |

  ## Examples

  The value must be a string.

      iex> {:ok, {forms, _}} = [
      ...>   deprecated: "This function has been deprecated since 1.7.9"
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@deprecated(\"This function has been deprecated since 1.7.9\")"]

  """

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
      validate_since: 1,
      validate_deprecated: 1
    ]

  import Plymio.Codi.CPO,
    only: [
      cpo_fetch_form: 1,
      cpo_get_since: 1,
      cpo_get_deprecated: 1,
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

  @doc false

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

  @doc false

  def cpo_pattern_since_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_since_dict_alias)
  end

  @pattern_deprecated_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_deprecated,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_deprecated_dict_alias @pattern_deprecated_kvs_alias
                                 |> opts_create_aliases_dict

  @doc false

  def cpo_pattern_deprecated_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_deprecated_dict_alias)
  end

  @doc false

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

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_deprecated do
    with {:ok, deprecated} <- cpo |> cpo_get_deprecated do
      deprecated
      |> is_value_unset
      |> case do
        true ->
          # drop the pattern
          {:ok, {[], state}}

        _ ->
          with {:ok, deprecated} <- deprecated |> validate_deprecated do
            pattern_form =
              quote do
                @deprecated unquote(deprecated)
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
