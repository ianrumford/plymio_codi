defmodule Plymio.Codi.Stage.Review do
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

  def pattern_review_item(codi, item)

  def pattern_review_item(%CODI{} = state, cpo) do
    cpo
    |> cpo_done_no_form?
    |> case do
      true ->
        {:ok, {[], state}}

      _ ->
        {:ok, {cpo, state}}
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
           {:produce_stage_worker_item, ctx, args} -> {:pattern_review_item, ctx, args}
           :PRODUCESTAGESTRUCT -> CODI
           x -> x
         end}
      ]
  )
end
