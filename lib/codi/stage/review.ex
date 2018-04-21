defmodule Plymio.Codi.Stage.Review do
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

  import Plymio.Codi.Utility.GetSet

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
    :def_produce_stage_worker_t_is_mccp0e_ozi_t,
    :def_produce_stage_field_items
  ]
  |> PFM.reify_proxies(
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
