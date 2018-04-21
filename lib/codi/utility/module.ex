defmodule Plymio.Codi.Utility.Module do
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
      is_value_unset: 1,
      is_value_unset_or_nil: 1
    ]

  import Plymio.Fontais.Error,
    only: [
      new_key_error_result: 2
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_validate: 1
    ]

  import Plymio.Funcio.Utility,
    only: [
      validate_fun_names: 1
    ]

  import Plymio.Codi.Utility,
    only: [
      validate_fun_module: 1
    ]

  # import Plymio.Codi.Utility.GetSet

  @type t :: %CODI{}
  @type error :: Plymio.Codi.error()

  @doc false

  def state_resolve_module_fva(state, module)

  def state_resolve_module_fva(
        %CODI{@plymio_codi_field_module_fva_dict => module_dict} = state,
        module
      )
      when is_value_unset(module_dict) do
    with {:ok, %CODI{} = state} <-
           state |> CODI.update([{@plymio_codi_field_module_fva_dict, %{}}]) do
      state |> state_resolve_module_fva(module)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def state_resolve_module_fva(
        %CODI{@plymio_codi_field_module_fva_dict => module_fva_dict} = state,
        module
      )
      when is_map(module_fva_dict) do
    with {:ok, module} <- module |> validate_fun_module do
      module_fva_dict
      |> Map.fetch(module)
      |> case do
        {:ok, fva} ->
          {:ok, {fva, state}}

        :error ->
          with {:ok, fva} <- module |> resolve_module_fva do
            module_fva_dict = module_fva_dict |> Map.put(module, fva)

            with {:ok, %CODI{} = state} <- state |> CODI.update_module_fva_dict(module_fva_dict) do
              {:ok, {fva, state}}
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

  @doc false

  def state_validate_mfa(codi, mfa)

  def state_validate_mfa(%CODI{} = state, {m, f, a} = mfa)
      when is_value_unset_or_nil(m) and is_atom(f) and is_integer(a) do
    {:ok, {mfa, state}}
  end

  def state_validate_mfa(%CODI{} = state, {m, f, a} = mfa)
      when is_atom(m) and is_atom(f) and is_integer(a) do
    with {:ok, {fva, %CODI{} = state}} <- state |> state_resolve_module_fva(m) do
      with {:ok, _} <- fva |> validate_mfa(mfa) do
        # the state is returned as well as module_dict may have been updated
        {:ok, {mfa, state}}
      else
        {:error, %{__exception__: true}} = result -> result
      end
    else
      {:error, %{__exception__: true}} ->
        new_error_result(m: "mfa #{inspect(mfa)} module unknown")
    end
  end

  def state_validate_mfa(_state, mfa) do
    new_error_result(m: "mfa invalid", v: mfa)
  end

  def validate_module_fva(fva)

  def validate_module_fva(fva) do
    with {:ok, fva} <- fva |> opts_validate do
      fva
      |> Keyword.values()
      |> Enum.split_with(&is_integer/1)
      |> case do
        {_ints, []} ->
          {:ok, fva}

        {_ints, _not_ints} ->
          new_error_result(m: "fva arities invalid", v: fva)
      end
    else
      {:error, %{__exception__: true} = error} ->
        new_error_result(m: "fva invalid", v: error)
    end
  end

  def reduce_module_fva(fva, opts \\ []) do
    with {:ok, fva} <- fva |> opts_validate,
         {:ok, opts} <- opts |> opts_validate do
      fva_keys = fva |> Keyword.keys() |> Enum.uniq()

      opts
      |> Enum.reduce_while(fva, fn
        {:take, takes}, fva ->
          with {:ok, takes} <- takes |> List.wrap() |> validate_fun_names do
            (Enum.uniq(takes) -- fva_keys)
            |> case do
              # no uknown funs
              [] ->
                {:cont, fva |> Keyword.take(takes)}

              keys ->
                new_key_error_result(keys, fva_keys)
            end
          else
            {:error, %{__struct__: _}} = result -> {:halt, result}
          end

        {:drop, drops}, fva ->
          with {:ok, drops} <- drops |> List.wrap() |> validate_fun_names do
            (Enum.uniq(drops) -- fva_keys)
            |> case do
              # no uknown funs
              [] ->
                {:cont, fva |> Keyword.drop(drops)}

              keys ->
                new_key_error_result(keys, fva_keys)
            end
          else
            {:error, %{__struct__: _}} = result -> {:halt, result}
          end

        {:filter, fun_filter}, fva ->
          {:cont, fva |> Enum.filter(fun_filter)}

        {:reject, fun_reject}, fva ->
          {:cont, fva |> Enum.reject(fun_reject)}

        _, fva ->
          {:cont, fva}
      end)
      |> case do
        {:error, %{__exception__: true}} = result -> result
        fva -> {:ok, fva}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def resolve_module_fva(module, opts \\ [])

  def resolve_module_fva(module, [])
      when is_atom(module) and not is_nil(module) do
    with {:ok, ^module} <- module |> ensure_module_compiled do
      fva = :functions |> module.__info__

      {:ok, fva}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def resolve_module_fva(module, opts)
      when is_atom(module) and not is_nil(module) do
    with {:ok, fva} <- module |> resolve_module_fva,
         {:ok, _fva} = result <- fva |> reduce_module_fva(opts) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def resolve_module_fva(module, _opts) do
    new_error_result(m: "module invalid", v: module)
  end

  @spec validate_mfa(any, any) :: {:ok, mfa} | {:error, error}

  def validate_mfa(fva, mfa)

  def validate_mfa(fva, {m, f, a} = mfa)
      when is_atom(m) and is_atom(f) and is_integer(a) do
    with {:ok, fva} <- fva |> validate_module_fva do
      fva
      |> Keyword.take([f])
      |> case do
        [] ->
          new_error_result(m: "mfa #{inspect(mfa)} function unknown")

        fva ->
          fva
          |> List.keyfind(a, 1)
          |> case do
            {^f, ^a} ->
              {:ok, mfa}

            x when is_nil(x) ->
              new_error_result(m: "mfa #{inspect(mfa)} arity unknown")
          end
      end
    else
      {:error, %{__exception__: true}} ->
        new_error_result(m: "mfa #{inspect(mfa)} module unknown")
    end
  end

  def validate_mfa(_fva, mfa) do
    new_error_result(m: "mfa invalid", v: mfa)
  end

  def ensure_module_compiled(module, opts \\ [])

  def ensure_module_compiled(module, []) do
    with {:ok, ^module} <- module |> validate_fun_module do
      # ensure loaded
      module
      |> Code.ensure_compiled()
      |> case do
        {:module, ^module} ->
          {:ok, module}

        {:error, reason} ->
          new_error_result(m: "module #{inspect(module)} invalid", v: reason)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
