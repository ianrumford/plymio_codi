defmodule Plymio.Codi.Pattern.Typespec do
  @moduledoc ~S"""
  The *typespec* patterns build [typespec](https://hexdocs.pm/elixir/typespecs.html) module attributes.

  Currently only `@spec` is supported.

  See `Plymio.Codi` for an overview and documentation terms.

  ## Convenience Aliases

  A number of convenience aliases are available to simplify the
  *typespec*  declaration, especially the result. Note the *Meaning* in the following
  table is quoted form (so, e.g. `:ok_atom` means `quote(do: {:ok, atom})`)

  | Alias | Meaning |
  | :---       | :---            |
  | `:result` | *`{:ok, any} \| {:error, error}`* |
  | `:ok_result` | *`{:ok, any}`* |
  | `:error_result` | *`{:error, error}`* |
  | `:bang_result` | *`any \| no_return`* |
  | `:ok_atom` | *`{:ok, atom}`* |
  | `:ok_binary` | *`{:ok, binary}`* |
  | `:ok_list` | *`{:ok, list}`* |
  | `:ok_keyword` | *`{:ok, keyword}`* |
  | `:ok_opts` | *`{:ok, keyword}`* |
  | `:ok_map` | *`{:ok, map}`* |
  | `:ok_tuple` | *`{:ok, tuple}`* |
  | `:ok_integer` | *`{:ok, integer}`* |
  | `:ok_float` | *`{:ok, float}`* |
  | `:ok_struct` | *`{:ok, struct}`* |
  | `:ok_t` | *`{:ok, t}`* |
  | `:atom_result` | *`{:ok, atom} \| {:error, error}`* |
  | `:binary_result` | *`{:ok, binary} \| {:error, error}`* |
  | `:list_result` | *`{:ok, list} \| {:error, error}`* |
  | `:keyword_result` | *`{:ok, keyword} \| {:error, error}`* |
  | `:opts_result` | *`{:ok, keyword} \| {:error, error}`* |
  | `:map_result` | *`{:ok, map} \| {:error, error}`* |
  | `:tuple_result` | *`{:ok, tuple} \| {:error, error}`* |
  | `:integer_result` | *`{:ok, integer} \| {:error, error}`* |
  | `:float_result` | *`{:ok, float} \| {:error, error}`* |
  | `:struct_result` | *`{:ok, struct} \| {:error, error}`* |
  | `:t_result` | *`{:ok, t} \| {:error, error}`* |

  ## Pattern: *typespec_spec*

  The *typespec_spec* pattern builds a `@spec` form.

  Valid keys in the pattern opts are:

  | Key | Aliases |
  | :---       | :---            |
  | `:typespec_spec_name` | *:name :spec_name, :fun_name, :function_name* |
  | `:typespec_spec_args` | *:args, :spec_args, :fun_args, :function_args* |
  | `:typespec_spec_arity` | *:arity, :spec_arity, :fun_arity, :function_arity* |
  | `:typespec_spec_result` | *:result, :spec_result, :fun_result, :function_result* |

  ## Examples

  When an `:arity` is given, the `:spec_args` will all be `any`.

      iex> {:ok, {forms, _}} = [
      ...>   spec: [name: :fun1, arity: 1, result: :integer]#
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@spec(fun1(any) :: integer)"]

  The function's `args` can be given explicitly. Here a list of atoms
  are given which will be normalised to the equivalent type var. Note also
  the `:spec_result` is an explicit form.

      iex> spec_result = quote(do: binary | atom)
      ...> {:ok, {forms, _}} = [
      ...>   spec: [spec_name: :fun2, args: [:atom, :integer], spec_result: spec_result]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@spec(fun2(atom, integer) :: binary | atom)"]

  These examples use the convenience aliases.

      iex> {:ok, {forms, _}} = [
      ...>   spec: [spec_name: :fun4, args: [:atom, :integer], spec_result: :atom_result]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@spec(fun4(atom, integer) :: {:ok, atom} | {:error, error})"]

      iex> {:ok, {forms, _}} = [
      ...>   spec: [spec_name: :fun4, args: [:atom, :integer],
      ...>   spec_result: [:ok_tuple, :ok_map, :error_result]]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@spec(fun4(atom, integer) :: {:ok, tuple} | {:ok, map} | {:error, error})"]

      iex> {:ok, {forms, _}} = [
      ...>   spec: [spec_name: :fun4, args: :struct, spec_result: :struct_result]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@spec(fun4(struct) :: {:ok, struct} | {:error, error})"]

  """

  alias Plymio.Codi, as: CODI
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_empty_list: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_take_canonical_keys: 2,
      opts_create_aliases_dict: 1
    ]

  import Plymio.Codi.Utility,
    only: [
      cpo_resolve_typespec_spec_name: 1,
      cpo_resolve_typespec_spec_args: 1,
      cpo_resolve_typespec_spec_result: 1
    ]

  import Plymio.Codi.CPO,
    only: [
      cpo_fetch_typespec_spec_result: 1,
      cpo_done_with_edited_form: 2,
      cpo_get_typespec_spec_opts: 1
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

  @doc false

  def cpo_pattern_typespec_spec_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_type_dict_alias)
  end

  @doc false

  def express_pattern(codi, pattern, cpo \\ [])

  def express_pattern(%CODI{} = state, pattern, cpo)
      when pattern == @plymio_codi_pattern_typespec_spec do
    with {:ok, cpo} <- cpo |> cpo_pattern_typespec_spec_normalise,
         {:ok, type_opts} <- cpo |> cpo_get_typespec_spec_opts do
      type_opts
      # nothing to do?
      |> is_empty_list
      |> case do
        true ->
          # no type wanted => drop the cpo
          {:ok, {[], state}}

        _ ->
          # need to confirm have a type_result first
          with {:ok, _} <- cpo |> cpo_fetch_typespec_spec_result,
               {:ok, type_name} <- cpo |> cpo_resolve_typespec_spec_name,
               {:ok, type_args} <- cpo |> cpo_resolve_typespec_spec_args,
               {:ok, type_result} <- cpo |> cpo_resolve_typespec_spec_result do
            form =
              quote do
                @spec unquote(type_name)(unquote_splicing(type_args)) :: unquote(type_result)
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
