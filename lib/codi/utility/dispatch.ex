defmodule Plymio.Codi.Utility.Dispatch do
  @moduledoc false

  use Plymio.Codi.Attribute

  import Plymio.Codi.Error,
    only: [
      new_error_result: 1
    ]

  import Plymio.Fontais.Error,
    only: [
      new_key_error_result: 2
    ]

  @type error :: Plymio.Codi.error()

  def reduce_pattern_dispatch_vector(vectors) do
    vectors
    |> Stream.map(fn
      vector when is_atom(vector) ->
        apply(vector, :pattern_dispatch_vector, [])

      vector when is_list(vector) ->
        vector
        |> Keyword.keyword?()
        |> case do
          true -> vector |> Enum.into(%{})
          _ -> vector
        end

      # map will be caught
      vector ->
        vector
    end)
    |> Enum.reduce_while(%{}, fn
      vector, dispatch when is_map(vector) ->
        {:cont, Map.merge(dispatch, vector)}

      vector, _dispatch ->
        {:halt, new_error_result(m: "pattern dispatch vector invalid", v: vector)}
    end)
    |> case do
      {:error, %{__exception__: true}} = result -> result
      dispatch -> dispatch |> validate_pattern_dispatch_vector
    end
  end

  def reduce_pattern_dispatch_vector!(vectors) do
    with {:ok, dispatch} <- vectors |> reduce_pattern_dispatch_vector do
      dispatch
    else
      {:error, %{__struct__: _} = error} -> raise error
    end
  end

  def validate_pattern_dispatch_vector(dispatch)

  def validate_pattern_dispatch_vector(dispatch) when is_map(dispatch) do
    with true <- dispatch |> Map.keys() |> Enum.all?(&is_atom/1) do
      with true <- dispatch |> Map.values() |> Enum.all?(&is_function(&1, 3)) do
        {:ok, dispatch}
      else
        _ ->
          new_error_result(m: "pattern dispatch vector values invalid", v: dispatch)
      end
    else
      _ ->
        new_error_result(m: "pattern dispatch vector keys invalid", v: dispatch)
    end
  end

  def validate_pattern_dispatch_vector(dispatch) do
    new_error_result(m: "pattern dispatch vector invalid", v: dispatch)
  end

  def fetch_key_pattern_dispatch_vector(codi, key)

  def fetch_key_pattern_dispatch_vector(
        %{:__struct__ => _, @plymio_codi_field_pattern_express_dispatch => dispatch_vector},
        key
      ) do
    dispatch_vector
    |> Map.fetch(key)
    |> case do
      {:ok, _} = result ->
        result

      :error ->
        new_key_error_result(key, dispatch_vector)
    end
  end
end
