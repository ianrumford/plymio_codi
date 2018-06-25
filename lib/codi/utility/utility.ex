defmodule Plymio.Codi.Utility do
  @moduledoc false

  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_positive_integer: 1,
      is_negative_integer: 1,
      is_value_set: 1,
      is_value_unset: 1,
      is_value_unset_or_nil: 1
    ]

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Utility,
    only: [
      validate_key: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opzioni_validate: 1,
      opts_normalise: 1,
      opts_validate: 1,
      opts_get: 2,
      opts_get: 3,
      opts_put: 3,
      opts_fetch: 2
    ]

  import Plymio.Fontais.Form,
    only: [
      form_validate: 1,
      forms_normalise: 1
    ]

  import Plymio.Funcio.Enum.Map.Collate,
    only: [
      map_collate0_enum: 2
    ]

  import Plymio.Fontais.Result,
    only: [
      normalise1_result: 1
    ]

  import Plymio.Codi.CPO

  @type error :: Plymio.Codi.error()

  defp validate_vars(vars)

  defp validate_vars([]) do
    {:ok, []}
  end

  defp validate_vars(vars) when is_list(vars) do
    vars
    |> Macro.validate()
    |> case do
      :ok ->
        {:ok, vars}

      _ ->
        new_error_result(m: "vars invalid", v: vars)
    end
  end

  defp normalise_vars(vars, opts \\ [])

  defp normalise_vars([], _) do
    {:ok, []}
  end

  defp normalise_vars(vars, opts) do
    vars
    |> List.wrap()
    |> case do
      [] ->
        []

      x when is_list(x) ->
        x
        |> Enum.map(fn
          arg when is_atom(arg) ->
            arg |> Macro.var(nil)

          # +ve => generate e.g. arg1, arg2 etc
          arg when is_positive_integer(arg) ->
            opts
            # prefix for generated var?
            |> Keyword.get(@plymio_codi_key_prefix)
            |> case do
              x when is_nil(x) ->
                arg |> Macro.generate_arguments(nil)

              x when is_atom(x) ->
                Range.new(0, arg - 1)
                |> Enum.map(fn v ->
                  "#{to_string(x)}#{inspect(v)}"
                  |> String.to_atom()
                  |> Macro.var(nil)
                end)
            end

          # -ve => generate same prefix var
          # (use for type related argument hence any as default prefix)
          arg when is_negative_integer(arg) ->
            opts
            # prefix for generated var?
            |> Keyword.get(@plymio_codi_key_prefix, :any)
            |> Macro.var(nil)
            |> List.duplicate(arg |> abs())

          # already a var? will be validated below
          arg ->
            arg
        end)
        |> List.flatten()
    end
    |> validate_vars
  end

  defp validate_fun_name(name)

  defp validate_fun_name(name) when is_atom(name) do
    {:ok, name}
  end

  defp validate_fun_name(name) do
    new_error_result(m: "function name invalid", v: name)
  end

  def validate_fun_module(module)

  def validate_fun_module(nil) do
    new_error_result(m: "function module invalid", v: nil)
  end

  def validate_fun_module(module) when is_atom(module) do
    {:ok, module}
  end

  def validate_fun_module(module) do
    new_error_result(m: "function module invalid", v: module)
  end

  def validate_fun_modules(modules)

  def validate_fun_modules(modules) when is_list(modules) do
    modules
    |> map_collate0_enum(&validate_fun_module/1)
  end

  def validate_fun_modules(modules) do
    new_error_result(m: "functions modules invalid", v: modules)
  end

  defp validate_fun_arity(arity)

  defp validate_fun_arity(arity) when is_positive_integer(arity) do
    {:ok, arity}
  end

  defp validate_fun_arity(arity) do
    new_error_result(m: "function arity invalid", v: arity)
  end

  def validate_fun_args(fun_args, ctrl \\ [])

  def validate_fun_args(fun_args, ctrl) when is_list(fun_args) do
    with {:ok, fun_arity} <- ctrl |> ctrl_get_fun_arity_value do
      cond do
        is_value_unset(fun_arity) ->
          {:ok, fun_args}

        is_positive_integer(fun_arity) ->
          case fun_arity === length(fun_args) do
            true ->
              {:ok, fun_args}

            _ ->
              new_error_result(
                m: "function arity constraint #{inspect(fun_arity)} not met",
                v: fun_args
              )
          end

        true ->
          new_error_result(m: "function arity constraint invalid", v: fun_arity)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def validate_fun_args(fun_args, _ctrl) do
    new_error_result(m: "fun args invalid", v: fun_args)
  end

  # many are convenience mnemonics

  defp normalise_type_arg(result)

  defp normalise_type_arg(args) when is_list(args) do
    args
    |> map_collate0_enum(&normalise_type_arg/1)
  end

  defp normalise_type_arg(key)
       when key in [
              :result,
              :ok_any_error_error
            ] do
    {:ok, quote(do: {:ok, any} | {:error, error})}
  end

  defp normalise_type_arg(key)
       when key in [
              :ok_result,
              :ok_any,
              :ok_value
            ] do
    {:ok, quote(do: {:ok, any})}
  end

  defp normalise_type_arg(key)
       when key in [
              :error_result,
              :error_error
            ] do
    {:ok, quote(do: {:error, error})}
  end

  defp normalise_type_arg(key)
       when key in [
              :bang_result,
              :any_no_return
            ] do
    {:ok, quote(do: any | no_return)}
  end

  defp normalise_type_arg(:ok_opts_error_error) do
    {:ok, quote(do: {:ok, opts} | {:error, error})}
  end

  defp normalise_type_arg(:opts_no_return) do
    {:ok, quote(do: opts | no_return)}
  end

  defp normalise_type_arg(:ok_atom) do
    {:ok, quote(do: {:ok, atom})}
  end

  defp normalise_type_arg(:ok_binary) do
    {:ok, quote(do: {:ok, binary})}
  end

  defp normalise_type_arg(:ok_keyword) do
    {:ok, quote(do: {:ok, keyword})}
  end

  defp normalise_type_arg(:ok_opts) do
    {:ok, quote(do: {:ok, keyword})}
  end

  defp normalise_type_arg(:ok_list) do
    {:ok, quote(do: {:ok, list})}
  end

  defp normalise_type_arg(:ok_map) do
    {:ok, quote(do: {:ok, map})}
  end

  defp normalise_type_arg(:ok_struct) do
    {:ok, quote(do: {:ok, struct})}
  end

  defp normalise_type_arg(:ok_t) do
    {:ok, quote(do: {:ok, t})}
  end

  defp normalise_type_arg(:ok_tuple) do
    {:ok, quote(do: {:ok, tuple})}
  end

  defp normalise_type_arg(:ok_boolean) do
    {:ok, quote(do: {:ok, boolean})}
  end

  defp normalise_type_arg(:ok_integer) do
    {:ok, quote(do: {:ok, integer})}
  end

  defp normalise_type_arg(:ok_float) do
    {:ok, quote(do: {:ok, float})}
  end

  defp normalise_type_arg(:atom_result) do
    {:ok, quote(do: {:ok, atom} | {:error, error})}
  end

  defp normalise_type_arg(:binary_result) do
    {:ok, quote(do: {:ok, binary} | {:error, error})}
  end

  defp normalise_type_arg(:list_result) do
    {:ok, quote(do: {:ok, list} | {:error, error})}
  end

  defp normalise_type_arg(:keyword_result) do
    {:ok, quote(do: {:ok, keyword} | {:error, error})}
  end

  defp normalise_type_arg(:opts_result) do
    {:ok, quote(do: {:ok, keyword} | {:error, error})}
  end

  defp normalise_type_arg(:map_result) do
    {:ok, quote(do: {:ok, map} | {:error, error})}
  end

  defp normalise_type_arg(:struct_result) do
    {:ok, quote(do: {:ok, struct} | {:error, error})}
  end

  defp normalise_type_arg(:t_result) do
    {:ok, quote(do: {:ok, t} | {:error, error})}
  end

  defp normalise_type_arg(:tuple_result) do
    {:ok, quote(do: {:ok, tuple} | {:error, error})}
  end

  defp normalise_type_arg(:integer_result) do
    {:ok, quote(do: {:ok, integer} | {:error, error})}
  end

  defp normalise_type_arg(:float_result) do
    {:ok, quote(do: {:ok, float} | {:error, error})}
  end

  defp normalise_type_arg(key) when is_atom(key) do
    {:ok, Macro.var(key, nil)}
  end

  defp normalise_type_arg(result) do
    result |> normalise_vars
  end

  defp cpo_resolve(cpo, ctrl) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, key} <- ctrl |> ctrl_fetch_key,
         {:ok, key} <- key |> validate_key,
         {:ok, fun} <- ctrl |> ctrl_get_fun_validate_value do
      cpo
      |> Keyword.has_key?(key)
      |> case do
        true ->
          with {:ok, value} <- cpo |> opts_fetch(key) do
            value
            |> fun.()
            |> normalise1_result
          else
            {:error, %{__exception__: true}} = result -> result
          end

        # any default?
        _ ->
          ctrl
          |> ctrl_has_fun_default_value?
          |> case do
            true ->
              with {:ok, default_value} <- ctrl |> ctrl_fetch_fun_default_value do
                default_value
                |> case do
                  # don't validate if unset
                  x when is_value_unset(x) ->
                    {:ok, x}

                  x ->
                    x
                    |> fun.()
                    |> normalise1_result
                end
              else
                {:error, %{__exception__: true}} = result -> result
              end

            _ ->
              {:ok, @plymio_fontais_the_unset_value}
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_module(cpo, ctrl \\ [])

  # can return :ok with nil or unset
  def cpo_resolve_fun_module(cpo, ctrl) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, fun_module_key} <- ctrl |> ctrl_get_fun_module_key,
         {:ok, ctrl} <- ctrl |> ctrl_put_key(fun_module_key),
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_validate_value(&validate_fun_module/1),
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_default_value(@plymio_fontais_the_unset_value),
         {:ok, _fun_module} = result <- cpo |> cpo_resolve(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_name(cpo, ctrl \\ [])

  def cpo_resolve_fun_name(cpo, ctrl) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, fun_name_key} <- ctrl |> ctrl_get_fun_name_key,
         {:ok, fun_name_key} <- fun_name_key |> validate_key,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_validate_value(&validate_fun_name/1),
         {:ok, ctrl} <- ctrl |> ctrl_put_key(fun_name_key),
         {:ok, _fun_name} = result <- cpo |> cpo_resolve(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_args(cpo, ctrl \\ [])

  def cpo_resolve_fun_args(cpo, ctrl) do
    with {:ok, cpo_args} <- cpo |> opts_validate,
         {:ok, ctrl_args} <- ctrl |> opts_validate,
         {:ok, fun_args_key} <- ctrl_args |> ctrl_get_fun_args_key,
         {:ok, fun_arity_key} <- ctrl_args |> ctrl_get_fun_arity_key,
         {:ok, ctrl_args} <- ctrl |> ctrl_put_fun_validate_value(&resolve_fun_args/1),
         {:ok, ctrl_args} <- ctrl_args |> ctrl_put_key(fun_args_key),
         {:ok, ctrl_args} <-
           ctrl_args |> ctrl_put_fun_default_value(@plymio_fontais_the_unset_value),
         {:ok, fun_args} <- cpo_args |> cpo_resolve(ctrl_args) do
      fun_args
      |> is_value_set
      |> case do
        true ->
          {:ok, fun_args}

        _ ->
          cpo_args
          |> Keyword.get(fun_arity_key, @plymio_fontais_the_unset_value)
          |> is_value_set
          |> case do
            true ->
              with {:ok, fun_arity} <- cpo_args |> cpo_resolve_guard_fun_arity(ctrl_args),
                   {:ok, _} = result <- fun_arity |> resolve_fun_args do
                result
              else
                {:error, %{__exception__: true}} ->
                  new_error_result(m: "fun arity invalid", v: cpo)
              end

            _ ->
              {:ok, @plymio_fontais_the_unset_value}
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_guard_fun_args(cpo, ctrl \\ [])

  def cpo_resolve_guard_fun_args(cpo, ctrl) do
    with {:ok, fun_args} <- cpo |> cpo_resolve_fun_args(ctrl) do
      fun_args
      |> is_value_set
      |> case do
        true ->
          fun_args |> validate_fun_args(ctrl)

        _ ->
          new_error_result(m: "fun args invalid", v: fun_args)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_arity(cpo, opts \\ [])

  def cpo_resolve_fun_arity(cpo, opts) do
    with {:ok, cpo_arity} <- cpo |> opts_validate,
         {:ok, opts_arity} <- opts |> opts_validate,
         {:ok, fun_arity_key} <- opts_arity |> ctrl_get_fun_arity_key,
         {:ok, fun_args_key} <- opts_arity |> ctrl_get_fun_args_key,
         {:ok, opts_arity} <- opts_arity |> ctrl_put_fun_validate_value(&validate_fun_arity/1),
         {:ok, opts_arity} <- opts_arity |> ctrl_put_key(fun_arity_key),
         {:ok, opts_arity} <-
           opts_arity |> ctrl_put_fun_default_value(@plymio_fontais_the_unset_value),
         {:ok, fun_arity} <- cpo_arity |> cpo_resolve(opts_arity) do
      fun_arity
      |> is_value_set
      |> case do
        true ->
          {:ok, fun_arity}

        _ ->
          cpo_arity
          |> Keyword.get(fun_args_key, @plymio_fontais_the_unset_value)
          |> is_value_set
          |> case do
            true ->
              with {:ok, fun_args} <- cpo_arity |> cpo_resolve_guard_fun_args(opts_arity) do
                {:ok, fun_args |> length}
              else
                {:error, %{__exception__: true}} ->
                  new_error_result(m: "fun arity invalid", v: cpo)
              end

            _ ->
              {:ok, @plymio_fontais_the_unset_value}
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_guard_fun_arity(cpo, ctrl \\ [])

  def cpo_resolve_guard_fun_arity(cpo, ctrl) do
    with {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity(ctrl) do
      fun_arity
      |> is_integer
      |> case do
        true ->
          {:ok, fun_arity}

        _ ->
          new_error_result(m: "fun arity invalid", v: fun_arity)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_doc(cpo, opts \\ [])

  def cpo_resolve_fun_doc(cpo, opts) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, fun_doc_key} <- opts |> ctrl_get_fun_doc_key,
         {:ok, opts} <- opts |> ctrl_put_key(fun_doc_key),
         {:ok, opts} <- opts |> ctrl_put_fun_default_value(@plymio_fontais_the_unset_value),
         {:ok, _fun_doc} = result <- cpo |> cpo_resolve(opts) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_guard_fun_field(cpo)

  def cpo_resolve_guard_fun_field(cpo) do
    cpo
    |> cpo_fetch_fun_key
    |> case do
      {:ok, fun_field} ->
        fun_field
        |> validate_key
        |> case do
          {:ok, _fun_field} = result ->
            result

          _ ->
            new_error_result(m: "fun field invalid", v: fun_field)
        end

      _ ->
        new_error_result(m: "fun field missing", v: cpo)
    end
  end

  def cpo_resolve_guard_fun_fields(cpo, ctrl \\ [])

  def cpo_resolve_guard_fun_fields(cpo, ctrl) do
    with {:ok, cpo} <- cpo |> cpo_normalise,
         {:ok, fun_fields} <- cpo |> cpo_fetch_fun_key,
         {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, fun_default} <- ctrl |> ctrl_get_fun_default_value,
         {:ok, fun_key_length} <- ctrl |> ctrl_get_fun_key_length,
         true <- true do
      fun_fields
      |> List.wrap()
      |> map_collate0_enum(fn
        {k, v} when is_atom(k) -> {:ok, {k, v}}
        k when is_atom(k) -> {:ok, {k, fun_default}}
        x -> new_error_result(m: "fun field invalid", v: x)
      end)
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, fun_fields} ->
          # any constraint on the number of fields?
          fun_key_length
          |> is_value_set
          |> case do
            true ->
              case fun_key_length === length(fun_fields) do
                true ->
                  {:ok, fun_fields}

                _ ->
                  new_error_result(
                    m: "function key/field length constraint #{inspect(fun_key_length)} not met",
                    v: fun_fields
                  )
              end

            # no constraint
            _ ->
              {:ok, fun_fields}
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_guard_field_values(cpo, ctrl \\ [])

  def cpo_resolve_guard_field_values(cpo, ctrl) do
    with {:ok, field_tuples} <- cpo |> cpo_resolve_guard_fun_fields(ctrl),
         {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, fun_build} <- ctrl |> ctrl_get_fun_build_value(&field_build_named_var/1),
         true <- true do
      field_tuples
      |> Enum.with_index()
      |> map_collate0_enum(fun_build)
      |> case do
        {:error, %{__struct__: _}} = result -> result
        {:ok, field_values} -> {:ok, {field_values, field_tuples}}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def field_build_named_var({{field, _value}, index})
      when is_atom(field) and is_integer(index) do
    index
    |> case do
      0 ->
        {:ok, {field, :field_value |> Macro.var(nil)}}

      _ ->
        {:ok, {field, "field_value#{to_string(index)}" |> String.to_atom() |> Macro.var(nil)}}
    end
  end

  def field_build_anon_var({{field, _value}, index})
      when is_atom(field) and is_integer(index) do
    {:ok, {field, :_ |> Macro.var(nil)}}
  end

  def cpo_resolve_guard_field_match(cpo, ctrl \\ [])

  def cpo_resolve_guard_field_match(cpo, ctrl) do
    with {:ok, {field_vars, field_tuples}} <- cpo |> cpo_resolve_guard_field_values(ctrl) do
      match_args = {:%{}, [], field_vars}

      match_form = {:%, [], [{:__MODULE__, [], nil}, match_args]}

      # convenience: include the first field var tuple explicitly
      {:ok, {field_vars |> hd, field_vars, field_tuples, match_form}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def opts_resolve_opts_fun_args(opts) do
    with {:ok, opts} <- opts |> opts_normalise do
      cond do
        # if fun_args explicitly given, must be correct!
        Keyword.has_key?(opts, @plymio_codi_key_fun_args) ->
          with {:ok, fun_args} <- opts |> cpo_resolve_fun_args do
            {:ok, fun_args}
          else
            {:error, %{__exception__: true}} = result -> result
          end

        true ->
          # this will look for arity
          with {:ok, fun_args} <- opts |> cpo_resolve_fun_args do
            {:ok, [Macro.var(:opts, nil) | fun_args |> Enum.slice(1..-1)]}
          else
            {:error, %{__exception__: true}} = result -> result
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_bang_module(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_module_key(@plymio_codi_key_bang_module),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_module(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_bang_name(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_name_key(@plymio_codi_key_bang_name),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_name(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_bang_args(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_args_key(@plymio_codi_key_bang_args),
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_arity_key(@plymio_codi_key_bang_arity),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_args(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_bang_doc(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_doc_key(@plymio_codi_key_bang_doc),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_doc(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_query_module(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_module_key(@plymio_codi_key_query_module),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_module(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_query_name(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_name_key(@plymio_codi_key_query_name),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_name(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_query_args(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_args_key(@plymio_codi_key_query_args),
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_arity_key(@plymio_codi_key_query_arity),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_args(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_query_doc(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_doc_key(@plymio_codi_key_query_doc),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_doc(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_delegate_module(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_module_key(@plymio_codi_key_delegate_module),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_module(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_delegate_name(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_name_key(@plymio_codi_key_delegate_name),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_name(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_delegate_args(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_args_key(@plymio_codi_key_delegate_args),
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_arity_key(@plymio_codi_key_delegate_arity),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_args(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_delegate_doc(cpo, ctrl \\ []) do
    with {:ok, ctrl} <- ctrl |> ctrl_normalise,
         {:ok, ctrl} <- ctrl |> ctrl_put_fun_doc_key(@plymio_codi_key_delegate_doc),
         {:ok, _} = result <- cpo |> cpo_resolve_fun_doc(ctrl) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def resolve_fun_args(args) do
    args
    |> case do
      x when is_positive_integer(x) ->
        # this will generate a list var1, var2, etc
        x

      x when is_negative_integer(x) ->
        # this will generate a list var1, var2, etc
        0 - x

      x when is_value_unset_or_nil(x) ->
        []

      x ->
        x |> List.wrap()
    end
    |> normalise_vars
  end

  def resolve_type_args(args) do
    args
    |> case do
      x when is_positive_integer(x) ->
        # this will generate a list of vars all called any
        0 - x

      x when is_negative_integer(x) ->
        # this will generate a list of vars all called any
        x

      x when is_value_unset_or_nil(x) ->
        []

      x ->
        x |> List.wrap()
    end
    |> normalise_vars
  end

  def cpo_resolve_typespec_spec_name(cpo) do
    with {:ok, cpo} <- cpo |> opts_validate do
      cpo
      |> Keyword.has_key?(@plymio_codi_key_typespec_spec_name)
      |> case do
        true ->
          cpo |> cpo_get_typespec_spec_name

        _ ->
          new_error_result(m: "cpo type name missing", v: cpo)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_typespec_spec_args(opts, default \\ @plymio_fontais_the_unset_value) do
    with {:ok, opts} <- opts |> opts_validate do
      cond do
        Keyword.has_key?(opts, @plymio_codi_key_typespec_spec_args) ->
          with {:ok, type_args} <- opts |> opts_get(@plymio_codi_key_typespec_spec_args),
               {:ok, _} = result <- type_args |> resolve_type_args do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end

        Keyword.has_key?(opts, @plymio_codi_key_typespec_spec_arity) ->
          with {:ok, type_arity} <- opts |> opts_get(@plymio_codi_key_typespec_spec_arity),
               {:ok, _type_arity} = result <- type_arity |> resolve_type_args do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end

        Keyword.has_key?(opts, @plymio_codi_key_fun_arity) ->
          with {:ok, fun_arity} <- opts |> opts_get(@plymio_codi_key_fun_arity) do
            fun_arity
            |> case do
              x when is_positive_integer(x) ->
                0 - x

              x ->
                0 - length(x |> List.wrap())
            end
            |> resolve_type_args
          else
            {:error, %{__exception__: true}} = result -> result
          end

        Keyword.has_key?(opts, @plymio_codi_key_fun_args) ->
          with {:ok, fun_args} <- opts |> opts_get(@plymio_codi_key_fun_args),
               {:ok, fun_args} <- fun_args |> resolve_fun_args,
               {:ok, _type_args} = result <- fun_args |> length |> resolve_type_args do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end

        true ->
          default
          |> resolve_type_args
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_typespec_spec_result(opts) do
    with {:ok, opts} <- opts |> opts_validate,
         {:ok, type_result} <- opts |> opts_get(@plymio_codi_key_typespec_spec_result, []) do
      type_result
      |> case do
        # only really useful if is 1 i.e. the result is any
        x when is_positive_integer(x) ->
          (0 - x) |> normalise_vars

        x ->
          x |> normalise_type_arg
      end
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, [form]} ->
          form |> form_validate

        {:ok, forms} when is_list(forms) ->
          with {:ok, forms} <- forms |> forms_normalise do
            form =
              forms
              |> Enum.reverse()
              |> Enum.reduce(fn f, s ->
                quote do
                  unquote(f) | unquote(s)
                end
              end)

            {:ok, form}
          else
            {:error, %{__exception__: true}} = result -> result
          end

        {:ok, form} ->
          form |> form_validate
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp option_getset_default_fun_namer(opts) do
    with {:ok, opts} <- opts |> opts_validate do
      opts
      |> Keyword.has_key?(@plymio_codi_key_fun_name)
      |> case do
        true ->
          opts |> opts_get(@plymio_codi_key_fun_name)

        _ ->
          with {:ok, pattern_name} <- opts |> opts_fetch(@plymio_codi_key_pattern),
               {:ok, fun_key} <- opts |> opts_fetch(@plymio_codi_key_fun_key) do
            {:ok, "#{to_string(pattern_name)}_#{to_string(fun_key)}" |> String.to_atom()}
          else
            {:error, %{__exception__: true}} = result -> result
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_namer(opts) do
    with {:ok, opts} <- opts |> opts_validate do
      opts
      |> Keyword.get(@plymio_codi_key_fun_namer, &option_getset_default_fun_namer/1)
      |> case do
        fun_namer when is_function(fun_namer, 1) ->
          namer = fn opts ->
            opts
            |> fun_namer.()
            |> case do
              {:error, %{__exception__: true}} = result -> result
              {:ok, _} = result -> result
              fun_name -> {:ok, fun_name}
            end
            |> case do
              {:error, %{__exception__: true}} = result ->
                result

              {:ok, fun_name} ->
                fun_name
                |> case do
                  x when is_atom(x) ->
                    opts |> opts_put(@plymio_codi_key_fun_name, x)

                  x when is_binary(x) ->
                    opts |> opts_put(@plymio_codi_key_fun_name, x |> String.to_atom())

                  x ->
                    new_error_result(m: "function namer result invalid", v: x)
                end
            end
          end

          {:ok, namer}

        x ->
          new_error_result(m: "function namer function invalid", v: x)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def opts_resolve_proxy_names(opts) do
    with {:ok, opts} <- opts |> opts_validate do
      opts
      |> Keyword.fetch(@plymio_codi_key_proxy_name)
      |> case do
        {:ok, proxy_name} ->
          proxy_name |> normalise_proxy_names

        :error ->
          new_error_result(m: "opts function proxy name missing", v: opts)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defp normalise_proxy_names(names) do
    names
    |> List.wrap()
    |> validate_proxy_names
  end

  defp validate_proxy_names(names)

  defp validate_proxy_names([]) do
    {:ok, []}
  end

  defp validate_proxy_names(names) when is_list(names) do
    names
    |> Enum.split_with(&is_atom/1)
    |> case do
      {names, []} ->
        {:ok, names}

      {_, invalid_names} ->
        new_error_result(m: "proxy names invalid", v: invalid_names)
    end
  end

  defp resolve_function_sig(m, f, a)

  defp resolve_function_sig(m, f, a)
       when m in [
              Plymio.Fontais.Option
            ] and a == 2 and
              f in [
                :opts_get,
                :opts_fetch
              ] do
    [opts: 0, key: 1]
  end

  defp resolve_function_sig(m, f, a)
       when m in [
              Plymio.Fontais.Option
            ] and f == :opts_get and a == 3 do
    [opts: 0, key: 1, default: 2]
  end

  defp resolve_function_sig(_m, _f, a) do
    a
    |> Macro.generate_arguments(nil)
    |> Enum.with_index()
  end

  def opts_create_fun_sig(opts) do
    with {:ok, opts} <- opts |> opts_normalise,
         {:ok, pattern} <- opts |> opts_fetch(@plymio_codi_key_pattern),
         {:ok, fun_module} <- opts |> cpo_resolve_fun_module,
         {:ok, fun_arity} <- opts |> opts_fetch(@plymio_codi_key_fun_arity) do
      fun_sig_base =
        0..(fun_arity - 1)
        |> Enum.map(fn index -> {"var#{to_string(index)}" |> String.to_atom(), index} end)

      fun_sig = resolve_function_sig(fun_module, pattern, fun_arity)

      fun_sig =
        (fun_sig_base ++ fun_sig)
        |> Enum.group_by(fn {_k, v} -> v end)
        |> Enum.map(fn {_v, kvs} -> kvs |> List.last() end)
        |> Enum.into(%{})

      opts |> opts_put(@plymio_codi_key_sig, fun_sig)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def validate_module_dict(module_dict)

  def validate_module_dict(dict) when is_map(dict) do
    with {:ok, _} <- dict |> Map.keys() |> validate_fun_modules,
         {:ok, _} <- dict |> Map.values() |> opzioni_validate do
      {:ok, dict}
    else
      {:error, %{__exception__: true} = error} ->
        new_error_result(m: "module dictionary invalid", v: error)
    end
  end

  def validate_module_dict(dict) do
    new_error_result(m: "module dictionary invalid", v: dict)
  end

  # validate since is a semver spec
  def validate_since(since)

  def validate_since(since) when is_binary(since) do
    since
    |> Version.parse()
    |> case do
      {:ok, _} ->
        {:ok, since}

      _ ->
        new_error_result(m: "since invalid", v: since)
    end
  end

  def validate_since(since) do
    new_error_result(m: "since invalid", v: since)
  end

  def validate_deprecated(deprecated) do
    deprecated
    |> case do
      x when is_binary(x) ->
        {:ok, x}

      _ ->
        new_error_result(m: "deprecated invalid", v: deprecated)
    end
  end
end
