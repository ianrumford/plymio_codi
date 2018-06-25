defmodule Plymio.Codi.Pattern.Proxy do
  @moduledoc ~S"""
  The *proxy* patterns manage the *vekil*.

  See `Plymio.Codi` for an overview and documentation terms.

  ## Pattern: *proxy_fetch*

  The *proxy_fetch* pattern fetches the *forom* of one or more *proxies* in the
  *vekil*.

  *proxy_fetch* maps directly to a `Plymio.Vekil.proxy_fetch/2` call on
  the *vekil*; all of the  *proxies* must exist else an error result will be
  returned.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:proxy_name` | *:proxy_names, :proxy, :proxies* |

  ## Examples

  A simple case fetching one *proxy*:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :add_1,
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_1(x)) do\n x + 1\n end"]

  If the *proxy* is not found, or there is no *vekil*, an error result will be returned.

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...> }
      ...> {:error, error} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :add_11,
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "proxy invalid, got: :add_11"

      iex> {:error, error} = [
      ...>   proxy: :add_11,
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "vekil missing"

      iex> vekil_dict = %{
      ...>    # a map is not a valid form
      ...>    add_1: %{a: 1},
      ...> }
      ...> {:error, error} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :add_1,
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "form invalid, got: %{a: 1}"

  Multiple proxies can be given in a list:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    sqr_x: quote(do: def(sqr_x(x), do: x * x)),
      ...>    sub_1: quote(do: def(sub_1(x), do: x - 1)),
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxies: [:add_1, :sqr_x, :sub_1]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_1(x)) do\n x + 1\n end",
       "def(sqr_x(x)) do\n x * x\n end",
       "def(sub_1(x)) do\n x - 1\n end"]

  A *proxy* can be a list of other proxies:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    sqr_x: quote(do: def(sqr_x(x), do: x * x)),
      ...>    sub_1: quote(do: def(sub_1(x), do: x - 1)),
      ...>    all: [:add_1, :sqr_x, :sub_1],
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :all
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_1(x)) do\n x + 1\n end",
       "def(sqr_x(x)) do\n x * x\n end",
       "def(sub_1(x)) do\n x - 1\n end"]

  When the *proxy* is a list of proxies, infinite loops are caught:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    sqr_x: quote(do: def(sqr_x(x), do: x * x)),
      ...>    sub_1: quote(do: def(sub_1(x), do: x - 1)),
      ...>    all_loop: [:add_1, :sqr_x, :sub_1, :all_loop],
      ...> }
      ...> {:error, error} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :all_loop
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "proxy seen before, got: :all_loop"

  It is more efficient to pre-create (ideally at compile time) the *vekil*:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    sqr_x: quote(do: def(sqr_x(x), do: x * x)),
      ...>    sub_1: quote(do: def(sub_1(x), do: x - 1)),
      ...>    all: [:add_1, :sqr_x, :sub_1],
      ...> }
      ...> {:ok, %Plymio.Vekil.Form{} = vekil} = [dict: vekil_dict] |>
      ...> Plymio.Vekil.Form.new
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil,
      ...>   proxy: :all
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_1(x)) do\n x + 1\n end",
       "def(sqr_x(x)) do\n x * x\n end",
       "def(sub_1(x)) do\n x - 1\n end"]

  In this example a `:forms_edit` is given renaming all the `x` vars to `a` vars, changing "1" to "42" and
  renaming the `add_` function to `incr_1`.

  > renaming  the vars in this example doesn't change the logic

      iex> postwalk_fun = fn
      ...>   1 -> 42
      ...>   x -> x
      ...> end
      ...> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    sqr_x: quote(do: def(sqr_x(x), do: x * x)),
      ...>    sub_1: quote(do: def(sub_1(x), do: x - 1)),
      ...>    all: [:add_1, :sqr_x, :sub_1],
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: [proxy: :all, forms_edit: [
      ...>     postwalk: postwalk_fun,
      ...>     rename_vars: [x: :a],
      ...>     rename_funs: [add_1: :incr_1]]]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(incr_1(a)) do\n a + 42\n end",
       "def(sqr_x(a)) do\n a * a\n end",
       "def(sub_1(a)) do\n a - 42\n end"]

  ## Pattern: *proxy_put*

  The *proxy_put* pattern puts one or more *proxies* and their *forom*, into the *vekil*.

  *proxy_put* maps directly to a `Plymio.Vekil.proxy_put/2` call on
  the *vekil*.

  If the *vekil* does not exist, a new `Plymio.Vekil.Form` will be created.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:proxy_args` | |

  ## Examples

  A simple case puting one *proxy* and then fetching it:

      iex> {:ok, {forms, _}} = [
      ...>   proxy_put: [add_1: quote(do: def(add_1(x), do: x + 1))],
      ...>   proxy_fetch: :add_1
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_1(x)) do\n x + 1\n end"]

  In this example the same *proxy* (`:add_1`) is fetched twice but the
  *proxy* is updated between the two fetches.

      iex> {:ok, {forms, _}} = [
      ...>   proxy_put: [add_1: quote(do: x = x + 1)],
      ...>   proxy_fetch: :add_1,
      ...>   proxy_put: [add_1: quote(do: x = x + 40)],
      ...>   proxy_fetch: :add_1
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_test_forms!(binding: [x: 1])
      {42, ["x = x + 1", "x = x + 40"]}

  Here an existing *proxy* (`:sqr_x`) is overriden. Note the
  "composite" *proxy* `:all` is resolved as late as possible and finds the updated `:sqr_x`:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: x = x + 1),
      ...>    sqr_x: quote(do: x = x * x),
      ...>    sub_1: quote(do: x = x - 1),
      ...>    all: [:add_1, :sqr_x, :sub_1],
      ...> }
      ...> {:ok, %Plymio.Vekil.Form{} = vekil} = [dict: vekil_dict] |>
      ...> Plymio.Vekil.Form.new
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil,
      ...>   # change the :sqr_x proxy to cube instead
      ...>   proxy_put: [sqr_x: quote(do: x = x * x * x)],
      ...>   proxy: :all
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_test_forms!(binding: [x: 7])
      {511, ["x = x + 1", "x = x * x * x", "x = x - 1"]}

  ## Pattern: *proxy_delete*

  The *proxy_delete* pattern delete one or more *proxies* from the
  *vekil*.  It can be used to change the behaviour of a subsequent `proxy_get` to use the `default`.

  No *vekil* and / or any unknown *proxy* are ridden out without causing an error.

  *proxy_delete* maps directly to a `Plymio.Vekil.proxy_delete/2` call on
  the *vekil*.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:proxy_name` | *:proxy_names, :proxy, :proxies* |

  ## Examples

  A simple case of deleting a *proxy* and then fetching it:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...> }
      ...> {:error, error} = [
      ...>   vekil: vekil_dict,
      ...>   proxy_delete: :add_1,
      ...>   proxy_fetch: :add_1
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "proxy invalid, got: :add_1"

  No *vekil* and / or unknown *proxies* are ridden out without causing an error:

      iex> {:ok, {[], codi}} = [
      ...>   proxy_delete: :add_1,
      ...>   proxy_delete: :does_not_matter
      ...> ] |> produce_codi
      ...> match?(%Plymio.Codi{}, codi)
      true

  ## Pattern: *proxy_get*

  The *proxy_get* pattern gets one or more *proxies* from the
  *vekil* but with an optional `default` to be returned (as a *forom*) if the *proxy* is not found.

  *proxy_get* maps directly to a `Plymio.Vekil.proxy_get/2` or `Plymio.Vekil.proxy_get/3` call on

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:proxy_name` | *:proxy_names, :proxy, :proxies* |
  | `:default` | |

  ## Examples

  Here the *proxy* exists in the *vekil*:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy_get: :add_1,
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_1(x)) do\n x + 1\n end"]

  If the *proxy* does not exists, and there is no `default`, no forms are returned:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy_get: :add_2,
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      []

  Here a default is provided. Note the `default` is automatically
  normalised to a *forom* and then realised.

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy_get: [proxy: :add_2, default: quote(do: def(add_42(x), do: x + 42))]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_42(x)) do\n x + 42\n end"]

  The `default` can be another *proxy* in the *vekil*:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    add_42: quote(do: def(add_42(x), do: x + 42)),
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy_get: [proxy_name: :add_2, default: :add_42]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_42(x)) do\n x + 42\n end"]

  If there is no *vekil* and no `default`, no forms are returned:

      iex> {:ok, {forms, _}} = [
      ...>   proxy_get: :add_2,
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      []

  No *vekil* but a default works as expected:

      iex> {:ok, {forms, _}} = [
      ...>   proxy_get: [proxy: :add_2, default: quote(do: def(add_42(x), do: x + 42))]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["def(add_42(x)) do\n x + 42\n end"]

  As many defaults as *proxies* are returned:

      iex> {:ok, {forms, _}} = [
      ...>   proxy_get: [
      ...>    proxy: [:x_sub_1, :a_mul_x, :not_a_proxy, :some_other_thing],
      ...>    default: quote(do: x = x + 1)]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_test_forms!(binding: [x: 1])
      {5, ["x = x + 1", "x = x + 1", "x = x + 1", "x = x + 1"]}

  """

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
      cpo_get_proxy_default: 1
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

  @doc false

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

  @doc false

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

  @doc false

  def cpo_pattern_proxy_delete_normalise(cpo, dict \\ nil) do
    cpo |> cpo_normalise(dict || @pattern_proxy_delete_dict_alias)
  end

  @pattern_proxy_get_kvs_alias [
    @plymio_codi_key_alias_pattern,
    @plymio_codi_key_alias_status,
    @plymio_codi_key_alias_proxy_name,
    @plymio_codi_key_alias_proxy_default,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_proxy_get_dict_alias @pattern_proxy_get_kvs_alias
                                |> opts_create_aliases_dict

  @doc false

  def cpo_pattern_proxy_get_normalise(cpo, dict \\ nil) do
    cpo |> cpo_normalise(dict || @pattern_proxy_get_dict_alias)
  end

  @doc false

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
         {:ok, default} <- cpo |> cpo_get_proxy_default,
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
