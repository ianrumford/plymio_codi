defmodule Plymio.Codi.Utility.Depend do
  @moduledoc false

  alias Plymio.Codi, as: CODI
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  import Plymio.Codi.CPO

  @type error :: Plymio.Codi.error()

  def cpo_transform_doc_depend(cpo) do
    with {:ok, cpo} <- cpo |> Plymio.Codi.Pattern.Doc.cpo_pattern_doc_normalise(),
         {:ok, cpo} <- cpo |> cpo_mark_status_active,
         {:ok, cpo} <- cpo |> cpo_drop_form,
         {:ok, cpo} <- cpo |> cpo_put_pattern(@plymio_codi_pattern_doc),
         {:ok, _cpo} = result <- cpo |> cpo_tidy do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_transform_since_depend(cpo) do
    with {:ok, cpo} <- cpo |> Plymio.Codi.Pattern.Other.cpo_pattern_since_normalise(),
         {:ok, cpo} <- cpo |> cpo_mark_status_active,
         {:ok, cpo} <- cpo |> cpo_drop_form,
         {:ok, cpo} <- cpo |> cpo_put_pattern(@plymio_codi_pattern_since),
         {:ok, _cpo} = result <- cpo |> cpo_tidy do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def cpo_transform_typespec_spec_depend(cpo) do
    with {:ok, cpo} <- cpo |> cpo_normalise,
         # delete the fun_args to stop confusion over type args;
         # fun_arity will be used if needed
         {:ok, cpo} <- cpo |> cpo_drop_fun_args,
         {:ok, cpo} <- cpo |> Plymio.Codi.Pattern.Typespec.cpo_pattern_typespec_spec_normalise(),
         {:ok, cpo} <- cpo |> cpo_mark_status_active,
         {:ok, cpo} <- cpo |> cpo_drop_form,
         {:ok, cpo} <- cpo |> cpo_put_pattern(@plymio_codi_pattern_typespec_spec),
         {:ok, _cpo} = result <- cpo |> cpo_tidy do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def create_depend_cpos(codi, cpo, depend_args \\ [])

  def create_depend_cpos(%CODI{} = state, _cpo, []) do
    {:ok, {[], state}}
  end

  def create_depend_cpos(%CODI{} = state, cpo, depend_args)
      when is_list(depend_args) do
    with {:ok, cpo} <- cpo |> cpo_normalise,
         {:ok, depend_args} <- depend_args |> normalise_cpo_transform_pipeline,
         true <- true do
      depend_args
      |> List.wrap()
      |> Plymio.Funcio.Enum.Map.Collate.map_collate2_enum(fn
        {fun_pred, fun_transform} ->
          cpo
          |> fun_pred.()
          |> case do
            true ->
              cpo |> cpo_transform(fun_transform)

            # drop if the predicate was not true
            _ ->
              nil
          end
      end)
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, depend_patterns} ->
          with {:ok, %CODI{} = depend_state} <- state |> CODI.update_snippets(depend_patterns),
               {:ok, {depend_product, %CODI{}}} <-
                 depend_state |> Plymio.Codi.Stage.Normalise.normalise_snippets(),
               {:ok, depend_cpos} <- depend_product |> cpo_fetch_patterns,
               true <- true do
            depend_cpos
            |> Enum.map(fn cpo -> cpo |> cpo_get_form(nil) |> elem(1) end)
            |> Enum.reject(&is_nil/1)

            {:ok, {depend_cpos, state}}
          else
            {:error, %{__exception__: true}} = result -> result
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end
end
