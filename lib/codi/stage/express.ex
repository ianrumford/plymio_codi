defmodule Plymio.Codi.Stage.Express do
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

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Codi.CPO

  def pattern_express_item(codi, item)

  def pattern_express_item(
        %CODI{@plymio_codi_field_pattern_express_dispatch => dispatch} = state,
        cpo
      )
      when is_map(dispatch) do
    cpo
    |> cpo_done?
    |> case do
      true ->
        {:ok, {cpo, state}}

      _ ->
        with {:ok, pattern} <- cpo |> cpo_fetch_pattern do
          dispatch
          |> Map.fetch(pattern)
          |> case do
            {:ok, dispatch_fun} ->
              # if the cpo has a state use it to express
              with {:ok, %CODI{} = cpo_state} <- cpo |> cpo_get_state(state),
                   {:ok, {cpo, %CODI{} = cpo_state}} <-
                     cpo_state
                     |> dispatch_fun.(pattern, cpo) do
                {:ok, {cpo, cpo_state}}
              else
                {:error, %{__exception__: true}} = result -> result
              end

            _ ->
              new_error_result(m: "pattern express dispatcher missing", v: pattern)
          end
        else
          {:error, %{__exception__: true}} = result -> result
        end
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
           {:produce_stage_worker_item, ctx, args} -> {:pattern_express_item, ctx, args}
           :PRODUCESTAGESTRUCT -> CODI
           x -> x
         end}
      ]
  )
end
