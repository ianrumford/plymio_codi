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

  import Plymio.Fontais.Error,
    only: [
      new_argument_error_result: 1
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

  import Plymio.Funcio.Enum.Map.Collate,
    only: [
      map_collate0_enum: 2
    ]

  import Plymio.Fontais.Result,
    only: [
      normalise1_result: 1
    ]

  import Plymio.Codi.Utility.GetSet

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
            # prefix for generated var?
            opts
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
            # prefix for generated var?
            opts
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

  # many are convenience mnemonics

  defp normalise_type_result(result)

  defp normalise_type_result(:ok_any_error_error) do
    {:ok, quote(do: {:ok, any} | {:error, error})}
  end

  defp normalise_type_result(:any_no_return) do
    {:ok, quote(do: any | no_return)}
  end

  defp normalise_type_result(:ok_opts_error_error) do
    {:ok, quote(do: {:ok, opts} | {:error, error})}
  end

  defp normalise_type_result(:opts_no_return) do
    {:ok, quote(do: opts | no_return)}
  end

  defp normalise_type_result(result) do
    result |> normalise_vars
  end

  defp cpo_resolve(cpo, opts) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, key} <- opts |> ctrl_fetch_key,
         {:ok, key} <- key |> validate_key,
         {:ok, fun} <- opts |> ctrl_get_validate_fun do
      cpo
      |> Keyword.has_key?(key)
      |> case do
        true ->
          cpo
          |> Keyword.get(key)
          |> fun.()
          |> normalise1_result

        # any default?
        _ ->
          opts
          |> Keyword.has_key?(@plymio_codi_key_default)
          |> case do
            true ->
              opts
              |> Keyword.get(@plymio_codi_key_default)
              |> case do
                # don't validate if unset
                x when is_value_unset(x) ->
                  {:ok, x}

                x ->
                  x
                  |> fun.()
                  |> normalise1_result
              end

            _ ->
              new_argument_error_result("cpo #{to_string(key)} missing, got: #{inspect(cpo)}")
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_module(cpo, opts \\ [])

  # can return :ok with nil or unset
  def cpo_resolve_fun_module(cpo, opts) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, fun_module_key} <- opts |> ctrl_get_key_fun_module,
         {:ok, opts} <- opts |> ctrl_put_key(fun_module_key),
         {:ok, opts} <- opts |> ctrl_put_validate_fun(&validate_fun_module/1),
         {:ok, opts} <- opts |> ctrl_put_default(@plymio_fontais_the_unset_value),
         {:ok, _fun_module} = result <- cpo |> cpo_resolve(opts) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_name(cpo, opts \\ [])

  def cpo_resolve_fun_name(cpo, opts) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, fun_name_key} <- opts |> ctrl_get_key_fun_name,
         {:ok, fun_name_key} <- fun_name_key |> validate_key,
         {:ok, opts} <- opts |> ctrl_put_validate_fun(&validate_fun_name/1),
         {:ok, opts} <- opts |> ctrl_put_key(fun_name_key),
         {:ok, _fun_name} = result <- cpo |> cpo_resolve(opts) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_args(cpo, opts \\ [])

  def cpo_resolve_fun_args(cpo, opts) do
    with {:ok, cpo_args} <- cpo |> opts_validate,
         {:ok, opts_args} <- opts |> opts_validate,
         {:ok, fun_args_key} <- opts_args |> ctrl_get_key_fun_args,
         {:ok, opts_args} <- opts |> ctrl_put_validate_fun(&resolve_fun_args/1),
         {:ok, opts_args} <- opts_args |> ctrl_put_key(fun_args_key),
         {:ok, opts_args} <- opts_args |> ctrl_put_default(@plymio_fontais_the_unset_value),
         {:ok, fun_args} <- cpo_args |> cpo_resolve(opts_args) do
      fun_args
      |> is_value_set
      |> case do
        true ->
          {:ok, fun_args}

        _ ->
          with {:ok, fun_arity} <- cpo |> cpo_resolve_fun_arity(opts),
               {:ok, _} = result <- fun_arity |> resolve_fun_args do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_arity(cpo, opts \\ [])

  def cpo_resolve_fun_arity(cpo, opts) do
    with {:ok, cpo_arity} <- cpo |> opts_validate,
         {:ok, opts_arity} <- opts |> opts_validate,
         {:ok, fun_arity_key} <- opts_arity |> ctrl_get_key_fun_arity,
         {:ok, opts_arity} <- opts |> ctrl_put_validate_fun(&validate_fun_arity/1),
         {:ok, opts_arity} <- opts_arity |> ctrl_put_key(fun_arity_key),
         {:ok, opts_arity} <- opts_arity |> ctrl_put_default(@plymio_fontais_the_unset_value),
         {:ok, fun_arity} <- cpo_arity |> cpo_resolve(opts_arity) do
      fun_arity
      |> is_value_set
      |> case do
        true ->
          {:ok, fun_arity}

        _ ->
          with {:ok, fun_args} <- cpo |> cpo_resolve_fun_args(opts) do
            {:ok, fun_args |> length}
          else
            {:error, %{__exception__: true}} = result -> result
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_fun_doc(cpo, opts \\ [])

  def cpo_resolve_fun_doc(cpo, opts) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, fun_doc_key} <- opts |> ctrl_get_key_fun_doc,
         {:ok, opts} <- opts |> ctrl_put_key(fun_doc_key),
         {:ok, opts} <- opts |> ctrl_put_default(@plymio_fontais_the_unset_value),
         {:ok, _fun_doc} = result <- cpo |> cpo_resolve(opts) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def opts_resolve_opts_fun_args(opts) do
    with {:ok, opts} <- opts |> opts_normalise do
      cond do
        # if fun_args explicilty give, must be correct!
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

      #   {:ok, [Macro.var(:opts,nil) | fun_args |> Enum.slice(1 .. -1)]}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_bang_module(cpo, opts \\ []) do
    with {:ok, opts} <- opts |> opts_validate do
      opts =
        opts ++
          [
            {@plymio_codi_key_fun_module, @plymio_codi_key_bang_module}
          ]

      cpo
      |> cpo_resolve_fun_module(opts)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_bang_name(cpo, opts \\ []) do
    with {:ok, opts} <- opts |> opts_validate do
      opts =
        opts ++
          [
            {@plymio_codi_key_fun_name, @plymio_codi_key_bang_name}
          ]

      cpo
      |> cpo_resolve_fun_name(opts)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_bang_args(cpo, opts \\ []) do
    with {:ok, opts} <- opts |> opts_validate do
      opts =
        opts ++
          [
            {@plymio_codi_key_fun_args, @plymio_codi_key_bang_args},
            {@plymio_codi_key_fun_arity, @plymio_codi_key_bang_arity}
          ]

      cpo
      |> cpo_resolve_fun_args(opts)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_bang_doc(cpo, opts \\ []) do
    with {:ok, opts} <- opts |> opts_validate do
      opts =
        opts ++
          [
            {@plymio_codi_key_fun_doc, @plymio_codi_key_bang_doc}
          ]

      cpo
      |> cpo_resolve_fun_doc(opts)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_delegate_module(cpo, opts \\ []) do
    with {:ok, opts} <- opts |> opts_validate do
      opts =
        opts ++
          [
            {@plymio_codi_key_fun_module, @plymio_codi_key_delegate_module}
          ]

      cpo
      |> cpo_resolve_fun_module(opts)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_delegate_name(cpo, opts \\ []) do
    with {:ok, opts} <- opts |> opts_validate do
      opts =
        opts ++
          [
            {@plymio_codi_key_fun_name, @plymio_codi_key_delegate_name}
          ]

      cpo
      |> cpo_resolve_fun_name(opts)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_delegate_args(cpo, opts \\ []) do
    with {:ok, opts} <- opts |> opts_validate do
      opts =
        opts ++
          [
            {@plymio_codi_key_fun_args, @plymio_codi_key_delegate_args},
            {@plymio_codi_key_fun_arity, @plymio_codi_key_delegate_arity}
          ]

      cpo
      |> cpo_resolve_fun_args(opts)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_delegate_doc(cpo, opts \\ []) do
    with {:ok, opts} <- opts |> opts_validate do
      opts =
        opts ++
          [
            {@plymio_codi_key_fun_doc, @plymio_codi_key_delegate_doc}
          ]

      cpo
      |> cpo_resolve_fun_doc(opts)
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

  def cpo_resolve_type_name(cpo) do
    with {:ok, cpo} <- cpo |> opts_validate do
      cpo
      |> Keyword.has_key?(@plymio_codi_key_typespec_spec_name)
      |> case do
        true ->
          cpo |> cpo_get_type_name

        _ ->
          new_error_result("cpo type name missing, got: #{inspect(cpo)}")
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_resolve_type_args(opts, default \\ @plymio_fontais_the_unset_value) do
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

  def cpo_resolve_type_result(opts) do
    with {:ok, opts} <- opts |> opts_validate,
         {:ok, type_result} <- opts |> opts_get(@plymio_codi_key_typespec_spec_result, []) do
      type_result
      |> case do
        # only really useful if is 1 i.e. the result is any
        x when is_positive_integer(x) ->
          (0 - x) |> normalise_vars

        x when is_list(x) ->
          with {:ok, result_vars} <- x |> normalise_vars do
            # how to build "properly"???
            [{:|, [], result_vars}]
            |> validate_vars
          else
            {:error, %{__exception__: true}} = result -> result
          end

        x when is_atom(x) ->
          x |> normalise_type_result

        x ->
          x |> normalise_vars
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
end
