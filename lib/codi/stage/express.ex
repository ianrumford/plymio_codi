defmodule Plymio.Codi.Stage.Express do
  @moduledoc false

  require Plymio.Fontais.Vekil, as: PFM
  alias Plymio.Codi, as: CODI

  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  @codi_opts [
    {@plymio_fontais_key_vekil, Plymio.Fontais.Codi.__vekil__()}
  ]

  @type t :: %CODI{}
  @type kv :: {any, any}
  @type error :: any

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Codi.Utility.GetSet

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
              state |> dispatch_fun.(pattern, cpo)

            _ ->
              new_error_result(m: "pattern express dispatcher missing", v: pattern)
          end
        else
          {:error, %{__exception__: true}} = result -> result
        end
    end
  end

  [
    :def_produce_stage_worker_t_is_mccp0e_ozi_t,
    :def_produce_stage_field_items
  ]
  |> PFM.reify_proxies(
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
