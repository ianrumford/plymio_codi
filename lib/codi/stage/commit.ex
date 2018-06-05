defmodule Plymio.Codi.Stage.Commit do
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

  import Plymio.Codi.CPO

  defp pattern_commit_spec(codi, pattern, cpo)

  defp pattern_commit_spec(%CODI{} = state, pattern, cpo)
       when pattern in [
              @plymio_codi_pattern_proxy_fetch
            ] do
    # "freeze" the state for this pattern
    with {:ok, cpo} <- cpo |> cpo_put_state(state) do
      {:ok, {cpo, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  # these change the state (i.e. vekil) to need to be done early
  defp pattern_commit_spec(%CODI{} = state, pattern, cpo)
       when pattern in [
              @plymio_codi_pattern_proxy_put,
              @plymio_codi_pattern_proxy_delete
            ] do
    state
    |> Plymio.Codi.Stage.Express.pattern_express_item(cpo)
    |> case do
      {:error, %{__struct__: _}} = result -> result
      {:ok, {[], %CODI{}}} = result -> result
    end
  end

  defp pattern_commit_spec(%CODI{} = state, _pattern, cpo) do
    # default is *not* to freeze the state in the cpo
    {:ok, {cpo, state}}
  end

  def pattern_commit_item(codi, item)

  def pattern_commit_item(%CODI{} = state, cpo) do
    cpo
    |> cpo_done?
    |> case do
      true ->
        {:ok, {cpo, state}}

      _ ->
        with {:ok, pattern} <- cpo |> cpo_fetch_pattern do
          state |> pattern_commit_spec(pattern, cpo)
        else
          {:error, %{__exception__: true}} = result -> result
        end
    end
  end

  [
    :workflow_def_produce_stage_worker_t_is_rp0e_ozi_t,
    :workflow_def_produce_stage_field_items
  ]
  |> VEKILUTIL.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           :produce_stage_field -> @plymio_codi_field_patterns
           {:produce_stage_worker_item, ctx, args} -> {:pattern_commit_item, ctx, args}
           :PRODUCESTAGESTRUCT -> CODI
           x -> x
         end}
      ]
  )
end
