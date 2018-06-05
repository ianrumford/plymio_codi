defmodule Plymio.Codi.Stage.Normalise do
  @moduledoc false

  require Plymio.Vekil.Utility, as: VEKILUTIL
  alias Plymio.Codi, as: CODI

  use Plymio.Fontais.Attribute
  use Plymio.Vekil.Attribute
  use Plymio.Codi.Attribute

  @codi_opts [
    {@plymio_vekil_key_vekil, Plymio.Vekil.Codi.__vekil__()}
  ]

  @type t :: %CODI{}
  @type kv :: {any, any}
  @type error :: any

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
      opzioni_normalise: 1,
      opts_normalise: 1,
      opts_validate: 1
    ]

  import Plymio.Funcio.Enum.Map.Collate,
    only: [
      map_collate0_enum: 2
    ]

  import Plymio.Codi.CPO

  def normalise_pattern_cpo(codi, cpo)

  def normalise_pattern_cpo(%CODI{@plymio_codi_field_pattern_normalisers => normalisers}, cpo) do
    with {:ok, cpo} <- cpo |> opts_validate,
         {:ok, pattern} <- cpo |> cpo_get_pattern do
      normalisers
      |> Map.fetch(pattern)
      |> case do
        {:ok, fun} ->
          with {:ok, cpo} <- cpo |> fun.(),
               {:ok, _cpo} = result <- cpo |> cpo_maybe_put_status(@plymio_codi_status_active) do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end

        _ ->
          new_error_result(m: "pattern #{inspect(pattern)} invalid", v: cpo)
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  # use spec to add defaults, etc

  def normalise_pattern_spec(value)

  def normalise_pattern_spec({k, v})
      when k in [
             @plymio_codi_pattern_proxy_fetch,
             @plymio_codi_pattern_proxy_get,
             @plymio_codi_pattern_proxy_delete
           ] do
    cond do
      Keyword.keyword?(v) -> {:ok, v}
      true -> {:ok, [{@plymio_codi_key_proxy_name, v}]}
    end
  end

  def normalise_pattern_spec({k, v})
      when k == @plymio_codi_pattern_proxy_put do
    cond do
      Keyword.keyword?(v) ->
        # could be the proxy_args or a cpo: use proxy_args key to decide
        v
        |> Keyword.has_key?(@plymio_codi_key_proxy_args)
        |> case do
          true ->
            {:ok, v}

          _ ->
            {:ok, [{@plymio_codi_key_proxy_args, v}]}
        end

      true ->
        new_error_result(m: "pattern :proxy_put item invalid", v: v)
    end
  end

  def normalise_pattern_spec({k, v})
      when k == @plymio_codi_pattern_proxy_get do
    cond do
      Keyword.keyword?(v) ->
        # could be the proxy_args or a cpo: use proxy_args key to decide
        v
        |> Keyword.has_key?(@plymio_codi_key_proxy_args)
        |> case do
          true ->
            {:ok, v}

          _ ->
            {:ok, [{@plymio_codi_key_proxy_args, v}]}
        end

      true ->
        new_error_result(m: "pattern :proxy_get item invalid", v: v)
    end
  end

  def normalise_pattern_spec({k, v})
      when k in [
             @plymio_codi_pattern_doc
           ] do
    cond do
      Keyword.keyword?(v) -> {:ok, v}
      true -> {:ok, [{@plymio_codi_key_fun_doc, v}]}
    end
  end

  def normalise_pattern_spec({k, v})
      when k in [
             @plymio_codi_pattern_since
           ] do
    cond do
      Keyword.keyword?(v) -> {:ok, v}
      true -> {:ok, [{@plymio_codi_key_since, v}]}
    end
  end

  def normalise_pattern_spec({k, v}) do
    # expect v to be an opts
    cond do
      Keyword.keyword?(v) ->
        {:ok, v}

      true ->
        new_error_result(m: "pattern #{inspect(k)} item invalid", v: v)
    end
  end

  def normalise_pattern_spec(v) do
    new_error_result(m: "pattern item invalid", v: v)
  end

  def normalise_pattern_item(value)

  def normalise_pattern_item(v) when is_list(v) do
    # will be validated later
    {:ok, v}
  end

  def normalise_pattern_item({@plymio_codi_key_pattern, v}) do
    # will be validated later
    {:ok, v}
  end

  def normalise_pattern_item({@plymio_codi_key_form, v}) do
    v
    |> Keyword.keyword?()
    |> case do
      true ->
        v |> cpo_put_pattern(@plymio_codi_pattern_form)

      _ ->
        with {:ok, cpo} <- [] |> cpo_put_pattern(@plymio_codi_pattern_form),
             {:ok, _cpo} = result <- cpo |> cpo_put_form(v) do
          result
        else
          {:error, %{__exception__: true}} = result -> result
        end
    end
  end

  def normalise_pattern_item({k, v}) do
    with {:ok, pattern} <- k |> canonical_cpo_pattern do
      # note can *not* validate the cpo yet
      cond do
        Keyword.keyword?(v) ->
          {:ok, v}

        is_map(v) ->
          v |> opts_normalise

        true ->
          {:ok, v}
      end
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, v} ->
          with {:ok, cpo} <- {pattern, v} |> normalise_pattern_spec,
               {:ok, _cpo} = result <- cpo |> cpo_put_pattern(pattern) do
            result
          else
            {:error, %{__exception__: true}} = result -> result
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def normalise_pattern_item(value) do
    new_error_result(m: "pattern invalid", v: value)
  end

  def pattern_normalise_item(stykki, item)

  def pattern_normalise_item(%CODI{} = state, item) do
    with {:ok, opzioni} <- item |> normalise_pattern_item,
         {:ok, opzioni} <- opzioni |> opzioni_normalise do
      opzioni
      |> map_collate0_enum(fn cpo ->
        cpo
        |> cpo_done?
        |> case do
          # leave alone if done
          true ->
            {:ok, cpo}

          _ ->
            state |> normalise_pattern_cpo(cpo)
        end
      end)
      |> case do
        {:error, %{__struct__: _}} = result -> result
        {:ok, opzioni} -> {:ok, {opzioni, state}}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  [
    :workflow_def_produce_stage_worker_t_is_mccp0e_ozi_t,
    :workflow_def_produce_stage_field_items
  ]
  |> VEKILUTIL.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           :produce_stage_field -> @plymio_codi_field_patterns
           {:produce_stage_worker_item, ctx, args} -> {:pattern_normalise_item, ctx, args}
           :PRODUCESTAGESTRUCT -> CODI
           x -> x
         end}
      ]
  )

  def normalise_snippets(codi)

  def normalise_snippets(%CODI{@plymio_codi_field_snippets => snippets} = state)
      when is_value_set(snippets) do
    with {:ok, {product, %CODI{} = state}} <- state |> produce_stage(snippets |> List.wrap()),
         {:ok, %CODI{} = state} <- state |> CODI.reset_snippets() do
      {:ok, {product, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def normalise_snippets(%CODI{@plymio_codi_field_snippets => snippets} = state)
      when is_value_unset_or_nil(snippets) do
    {:ok, {[], state}}
  end
end
