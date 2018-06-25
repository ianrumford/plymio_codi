defmodule Plymio.Codi.Pattern.Doc do
  @moduledoc ~S"""
  The *doc* pattern builds an `@doc` module attribute.

  See `Plymio.Codi` for an overview and documentation terms.

  ## Pattern: *doc*

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:fun_name` | *:name, :spec_name, :fun_name, :function_name* |
  | `:fun_args` | *:args, :spec_args, :fun_args, :function_args* |
  | `:fun_arity` | *:arity, :spec_arity, :fun_arity, :function_arity* |
  | `:fun_doc` | *:doc, :function_doc* |

  ## Examples

  If the `:fun_doc` is `false`, documentation is turned off as expected:

      iex> {:ok, {forms, _}} = [
      ...>   doc: [doc: false]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@doc(false)"]

  The simplest `:fun_doc` is a string:

      iex> {:ok, {forms, _}} = [
      ...>   doc: [doc: "This is the docstring for fun1"]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@doc(\"This is the docstring for fun1\")"]

  For convenience, the `:fun_doc` can be `:bang` to generate a
  suitable docstring for a bang function. For this, the *cpo* must include the
  `:fun_name`, `:fun_args` or `:fun_arity`, and (optionally)
  `:fun_module`.

      iex> {:ok, {forms, _}} = [
      ...>   doc: [name: :fun_one, arity: 1, doc: :bang]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@doc(\"Bang function for `fun_one/1`\")"]

      iex> {:ok, {forms, _}} = [
      ...>   doc: [name: :fun_due, arity: 2, module: ModuleA, doc: :bang]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@doc(\"Bang function for `ModuleA.fun_due/2`\")"]

  Similarly, `:fun_doc` can be `:delegate` to generate a suitable
  docstring for a delegation.

      iex> {:ok, {forms, _}} = [
      ...>   doc: [name: :fun_due, arity: 2, doc: :delegate]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@doc(\"Delegated to `fun_due/2`\")"]

      iex> {:ok, {forms, _}} = [
      ...>   doc: [name: :fun_due, arity: 2, module: ModuleA, doc: :delegate]
      ...> ] |> produce_codi
      ...> forms |> harnais_helper_show_forms!
      ["@doc(\"Delegated to `ModuleA.fun_due/2`\")"]

  """

  alias Plymio.Codi, as: CODI
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Guard,
    only: [
      is_value_unset: 1,
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
      cpo_resolve_fun_arity: 1,
      cpo_resolve_guard_fun_fields: 1
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
    @plymio_codi_key_alias_fun_key,
    @plymio_codi_key_alias_fun_default,
    @plymio_codi_key_alias_delegate_name,
    @plymio_codi_key_alias_forms_edit
  ]

  @pattern_doc_dict_alias @pattern_doc_kvs_alias
                          |> opts_create_aliases_dict

  @doc false

  def cpo_pattern_doc_normalise(opts, dict \\ nil) do
    opts |> opts_take_canonical_keys(dict || @pattern_doc_dict_alias)
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
       when pattern == @plymio_codi_doc_type_query do
    with {:ok, fun_name} <- opts |> cpo_resolve_fun_name,
         {:ok, fun_module} <- opts |> cpo_resolve_fun_module,
         {:ok, fun_arity} <- opts |> cpo_resolve_fun_arity do
      docstring =
        fun_module
        |> case do
          x when is_value_unset_or_nil(x) ->
            "Query function for `#{to_string(fun_name)}/#{fun_arity}`"

          x ->
            "Query function for `#{inspect(x)}.#{to_string(fun_name)}/#{fun_arity}`"
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

  defp express_doc_pattern(%CODI{} = state, pattern, cpo)
       when pattern == @plymio_codi_doc_type_struct_get1 do
    with {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity,
         {:ok, fun_default} <- cpo |> cpo_get_fun_default,
         {:ok, fun_fields} <- cpo |> cpo_resolve_guard_fun_fields,
         {:ok, fun_args} <- cpo |> cpo_fetch_fun_args,
         true <- true do
      fun_field = fun_fields |> hd |> elem(0)

      fun_default =
        fun_default
        |> is_value_unset
        |> case do
          true -> "TheUnsetValue"
          _ -> fun_default |> inspect
        end

      edits = [
        {~r/proxy_fun_name/, fun_name |> to_string},
        {~r/proxy_fun_arity/, fun_arity |> to_string},
        {~r/proxy_fun_default/, fun_default},
        {~r/proxy_field_name/, fun_field |> to_string},
        {~r/proxy_struct_name/, fun_args |> Enum.at(0) |> elem(0) |> to_string}
      ]

      docstring =
        ~S"""
        `proxy_fun_name/proxy_fun_arity` takes `proxy_struct_name`
        and, if the `proxy_field_name` field's `value`
        is set, returns `{:ok, value}`, else `{:ok, proxy_fun_default}`.
        """
        |> apply_doctsring_edits(edits)

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, cpo)
       when pattern == @plymio_codi_doc_type_struct_get2 do
    with {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity,
         {:ok, fun_fields} <- cpo |> cpo_resolve_guard_fun_fields,
         {:ok, fun_args} <- cpo |> cpo_fetch_fun_args,
         true <- true do
      fun_field = fun_fields |> hd |> elem(0)

      edits = [
        {~r/proxy_fun_name/, fun_name |> to_string},
        {~r/proxy_fun_arity/, fun_arity |> to_string},
        {~r/proxy_field_name/, fun_field |> to_string},
        {~r/proxy_struct_name/, fun_args |> Enum.at(0) |> elem(0) |> to_string},
        {~r/proxy_default_name/, fun_args |> Enum.at(1) |> elem(0) |> to_string}
      ]

      docstring =
        ~S"""
        `proxy_fun_name/proxy_fun_arity` takes `proxy_struct_name`
        and the `proxy_default_name` and, if the `proxy_field_name` field's `value`
        is set, returns `{:ok, value}`, else `{:ok, proxy_default_name}`.
        """
        |> apply_doctsring_edits(edits)

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, cpo)
       when pattern == @plymio_codi_doc_type_struct_fetch do
    with {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity,
         {:ok, fun_fields} <- cpo |> cpo_resolve_guard_fun_fields,
         {:ok, fun_args} <- cpo |> cpo_fetch_fun_args,
         true <- true do
      fun_field = fun_fields |> hd |> elem(0)

      edits = [
        {~r/proxy_fun_name/, fun_name |> to_string},
        {~r/proxy_fun_arity/, fun_arity |> to_string},
        {~r/proxy_field_name/, fun_field |> to_string},
        {~r/proxy_struct_name/, fun_args |> Enum.at(0) |> elem(0) |> to_string}
      ]

      docstring =
        ~S"""
        `proxy_fun_name/proxy_fun_arity` takes `proxy_struct_name`
        and fetches field `proxy_field_name`'s `value`,
        and, if `value` is set, returns `{:ok, value}`, else `{:error, error}`
        """
        |> apply_doctsring_edits(edits)

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, cpo)
       when pattern == @plymio_codi_doc_type_struct_put do
    with {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity,
         {:ok, fun_fields} <- cpo |> cpo_resolve_guard_fun_fields,
         {:ok, fun_args} <- cpo |> cpo_fetch_fun_args,
         true <- true do
      fun_field = fun_fields |> hd |> elem(0)

      edits = [
        {~r/proxy_fun_name/, fun_name |> to_string},
        {~r/proxy_fun_arity/, fun_arity |> to_string},
        {~r/proxy_field_name/, fun_field |> to_string},
        {~r/proxy_struct_name/, fun_args |> Enum.at(0) |> elem(0) |> to_string},
        {~r/proxy_value_name/, fun_args |> Enum.at(1) |> elem(0) |> to_string}
      ]

      docstring =
        ~S"""
        `proxy_fun_name/proxy_fun_arity` takes `proxy_struct_name`
         and `proxy_value_name`, and puts
        `proxy_value_name` in `proxy_struct_name`'s field `proxy_field_name`,
        returning `{:ok, proxy_struct_name}`.
        """
        |> apply_doctsring_edits(edits)

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, cpo)
       when pattern == @plymio_codi_doc_type_struct_maybe_put do
    with {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity,
         {:ok, fun_fields} <- cpo |> cpo_resolve_guard_fun_fields,
         {:ok, fun_args} <- cpo |> cpo_fetch_fun_args,
         true <- true do
      fun_field = fun_fields |> hd |> elem(0)

      edits = [
        {~r/proxy_fun_name/, fun_name |> to_string},
        {~r/proxy_fun_arity/, fun_arity |> to_string},
        {~r/proxy_field_name/, fun_field |> to_string},
        {~r/proxy_struct_name/, fun_args |> Enum.at(0) |> elem(0) |> to_string},
        {~r/proxy_value_name/, fun_args |> Enum.at(1) |> elem(0) |> to_string}
      ]

      docstring =
        ~S"""
        `proxy_fun_name/proxy_fun_arity` takes `proxy_struct_name` and
        `proxy_value_name`, and, if `proxy_value_name` is set, and the
        value of the `proxy_field_name` field is unset,
        puts `proxy_value_name` in the `proxy_field_name` field,
        returning `{:ok, proxy_struct_name}`.
        """
        |> apply_doctsring_edits(edits)

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, cpo)
       when pattern == @plymio_codi_doc_type_struct_has? do
    with {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity,
         {:ok, fun_fields} <- cpo |> cpo_resolve_guard_fun_fields,
         {:ok, fun_args} <- cpo |> cpo_fetch_fun_args,
         true <- true do
      fun_field = fun_fields |> hd |> elem(0)

      edits = [
        {~r/proxy_fun_name/, fun_name |> to_string},
        {~r/proxy_fun_arity/, fun_arity |> to_string},
        {~r/proxy_field_name/, fun_field |> to_string},
        {~r/proxy_struct_name/, fun_args |> Enum.at(0) |> elem(0) |> to_string}
      ]

      docstring =
        ~S"""
        `proxy_fun_name/proxy_fun_arity` takes `proxy_struct_name`
        and, if its `proxy_field_name` field is
        set, returns `true`, else `false`.
        """
        |> apply_doctsring_edits(edits)

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, cpo)
       when pattern == @plymio_codi_doc_type_struct_set do
    with {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity,
         {:ok, fun_fields} <- cpo |> cpo_resolve_guard_fun_fields,
         {:ok, fun_args} <- cpo |> cpo_fetch_fun_args,
         true <- true do
      fun_fields =
        fun_fields
        |> Enum.map(fn
          {k, v} when is_value_unset(v) -> {k, "TheUnsetValue"}
          x -> x
        end)

      edits = [
        {~r/proxy_fun_name/, fun_name |> to_string},
        {~r/proxy_fun_arity/, fun_arity |> to_string},
        {~r/proxy_fun_default/, fun_fields |> inspect},
        {~r/proxy_struct_name/, fun_args |> Enum.at(0) |> elem(0) |> to_string}
      ]

      docstring =
        ~S"""
        `proxy_fun_name/proxy_fun_arity` takes `proxy_struct_name` and
        calls `Kernel.struct/1` with it and

             proxy_fun_default

        returning `{:ok, proxy_struct_name}`.
        """
        |> apply_doctsring_edits(edits)

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, cpo)
       when pattern == @plymio_codi_doc_type_struct_update do
    with {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity,
         {:ok, fun_fields} <- cpo |> cpo_resolve_guard_fun_fields,
         {:ok, fun_args} <- cpo |> cpo_fetch_fun_args,
         true <- true do
      fun_field = fun_fields |> hd |> elem(0)

      edits = [
        {~r/proxy_fun_name/, fun_name |> to_string},
        {~r/proxy_fun_arity/, fun_arity |> to_string},
        {~r/proxy_field_name/, fun_field |> to_string},
        {~r/proxy_struct_name/, fun_args |> Enum.at(0) |> elem(0) |> to_string},
        {~r/proxy_value_name/, fun_args |> Enum.at(1) |> elem(0) |> to_string}
      ]

      docstring =
        ~S"""
        `proxy_fun_name/proxy_fun_arity` takes `proxy_struct_name` and
        the `proxy_value_name` and calls `update/2` with
        [{`proxy_field_name`, `proxy_value_name`}], returning `{:ok, struct}`.
        """
        |> apply_doctsring_edits(edits)

      form =
        quote do
          @doc unquote(docstring)
        end

      {:ok, {form, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp express_doc_pattern(%CODI{} = state, pattern, cpo)
       when pattern == @plymio_codi_doc_type_struct_export do
    with {:ok, fun_name} <- cpo |> cpo_resolve_fun_name,
         {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity,
         {:ok, fun_fields} <- cpo |> cpo_resolve_guard_fun_fields,
         true <- true do
      edits = [
        {~r/proxy_fun_name/, fun_name |> to_string},
        {~r/proxy_fun_arity/, fun_arity |> to_string},
        {~r/proxy_fun_fields/, fun_fields |> Keyword.keys() |> inspect}
      ]

      docstring =
        ~S"""
        `proxy_fun_name/proxy_fun_arity` takes an instance of the
        module's *struct* and creates an *opts* (`Keyword`) from fields
        `proxy_fun_fields` whose values are set, returning `{:ok, opts}`.
        """
        |> apply_doctsring_edits(edits)

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

  @doc false

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

  defp apply_doctsring_edits(docstring, edits)
       when is_list(edits) and is_binary(docstring) do
    edits
    |> Enum.reduce(docstring, fn {r, v}, s ->
      Regex.replace(r, s, v)
    end)
  end
end
