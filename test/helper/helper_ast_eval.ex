defmodule PlymioCodiAstEvalAttributeHelper do
  defmacro __using__(_opts \\ []) do
    quote do
      @helper_opts_key_transform :transform
      @helper_opts_key_binding :binding
      @helper_opts_key_expect_error :expect_error
      @helper_opts_key_expect_value :expect_value
      @helper_opts_key_expect_text :expect_text
      @helper_opts_key_expect_texts :expect_texts
      @helper_opts_key_expect_form :expect_form
      @helper_opts_key_dictionary :dictionary
      @helper_opts_key_forms_collection :forms_collection
    end
  end
end

defmodule PlymioCodiAstEvalHelper do
  use PlymioCodiAstEvalAttributeHelper

  import Plymio.Fontais.Utility,
    only: [
      list_wrap_flat_just: 1
    ]

  import Plymio.Fontais.Form,
    only: [
      form_validate: 1,
      forms_validate: 1,
      forms_reduce: 1,
      forms_normalise: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opts_canonical_keys: 2,
      opts_create_aliases_dict: 1
    ]

  import Plymio.Funcio.Enum.Map.Collate,
    only: [
      map_collate0_enum: 2
    ]

  @helper_codi_eval_kvs_aliases [
    {@helper_opts_key_forms_collection, [:forms]},
    {@helper_opts_key_dictionary, nil},
    {@helper_opts_key_transform, nil},
    {@helper_opts_key_binding, nil},
    {@helper_opts_key_expect_value, [:compare_value, :result, :compare_result]},
    {@helper_opts_key_expect_text, [:text, :compare_text]},
    {@helper_opts_key_expect_texts, [:texts, :compare_texts]},
    {@helper_opts_key_expect_form, [:compare_form, :expect_ast, :compare_ast]},
    {@helper_opts_key_expect_error, [:compare_error, :error]}
  ]

  @helper_codi_eval_dict_aliases @helper_codi_eval_kvs_aliases
                                 |> opts_create_aliases_dict

  def helper_codi_eval_opts_canon_keys!(opts, dict \\ @helper_codi_eval_dict_aliases) do
    with {:ok, opts} <- opts |> opts_canonical_keys(dict) do
      opts
    else
      {:error, %{__struct__: _} = error} -> raise error
    end
  end

  def helper_codi_eval_normalise_error(error, opts \\ [])

  def helper_codi_eval_normalise_error(error, _opts) do
    cond do
      is_binary(error) -> error
      Exception.exception?(error) -> error |> Exception.message()
      is_atom(error) -> error |> to_string
      true -> error |> inspect
    end
  end

  def helper_codi_eval_compare(actual, expect_key, opts \\ [])

  def helper_codi_eval_compare(actual, @helper_opts_key_expect_text = expect_key, opts)
      when is_list(opts) do
    with {:ok, actual_clean} <- actual |> helper_codi_clean_text do
      # any result to compare?
      case opts |> Keyword.has_key?(expect_key) do
        true ->
          with {:ok, expect_clean} <- opts |> Keyword.get(expect_key) |> helper_codi_clean_text do
            case expect_clean == actual_clean do
              true ->
                {:ok, {actual_clean, actual}}

              _ ->
                {:error,
                 %ArgumentError{
                   message:
                     "mismatch; expect_key #{inspect(expect_key)}; expect_text: #{
                       inspect(expect_clean)
                     }; actual_text: #{inspect(actual_clean)}"
                 }}
            end
          else
            {:error, %{__exception__: true}} = result -> result
          end

        # nothing to do
        _ ->
          {:ok, {actual_clean, actual}}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_codi_eval_compare(ast, @helper_opts_key_expect_texts = expect_key, opts)
      when is_list(opts) do
    with {:ok, actual_texts} <- ast |> helper_asts_clean_text do
      # any result to compare?
      case opts |> Keyword.has_key?(expect_key) do
        true ->
          with {:ok, expect_texts} <- opts |> Keyword.get(expect_key) |> helper_asts_clean_text do
            case expect_texts == actual_texts do
              true ->
                {:ok, {actual_texts, ast}}

              _ ->
                {:error,
                 %ArgumentError{
                   message:
                     "mismatch; expect_key #{inspect(expect_key)}; expect_texts: #{
                       inspect(expect_texts)
                     }; actual_texts: #{inspect(actual_texts)}"
                 }}
            end
          else
            {:error, %{__exception__: true}} = result -> result
          end

        # nothing to do
        _ ->
          {:ok, {actual_texts, ast}}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_codi_eval_compare(ast, @helper_opts_key_expect_form = expect_key, opts)
      when is_list(opts) do
    # need to reduce the ast(s) first and eval that.
    with {:ok, actual_form} <- ast |> forms_reduce do
      actual_text = actual_form |> Macro.to_string()

      # anything to compare?
      case opts |> Keyword.has_key?(expect_key) do
        true ->
          expect_form = opts |> Keyword.get(expect_key)

          case expect_form == actual_form do
            true ->
              {:ok, {actual_text, actual_form}}

            _ ->
              {:error,
               %ArgumentError{
                 message:
                   "mismatch; expect_key #{inspect(expect_key)}; expect_form: #{
                     inspect(expect_form)
                   }; actual_form: #{inspect(actual_form)}"
               }}
          end

        # nothing to do
        _ ->
          {:ok, {actual_text, actual_form}}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_codi_eval_compare(ast, @helper_opts_key_binding = expect_key, opts)
      when is_atom(expect_key) and is_list(opts) do
    case opts |> Keyword.has_key?(expect_key) do
      x when x in [nil, false] ->
        {:ok, {nil, nil, ast}}

      _ ->
        binding = opts |> Keyword.get(expect_key)

        # need to reduce the ast(s) first and eval that.
        with {:ok, actual_form} <- ast |> forms_reduce,
             {:ok, actual_text} <- actual_form |> helper_codi_clean_text,
             {actual_value, _binding} <- actual_form |> Code.eval_quoted(binding, __ENV__) do
          # any compares?
          with {:ok, _} <-
                 helper_codi_eval_compare(actual_value, @helper_opts_key_expect_value, opts),
               {:ok, _} <-
                 helper_codi_eval_compare(actual_text, @helper_opts_key_expect_text, opts),
               {:ok, _} <-
                 helper_codi_eval_compare(actual_form, @helper_opts_key_expect_form, opts) do
            # compares ok
            {:ok, {actual_value, [actual_text], actual_form}}
          else
            {:error, %{__exception__: true}} = result -> result
          end
        else
          error -> {:error, %ArgumentError{message: "eval_failed; reason: #{inspect(error)}"}}
        end
    end
  end

  def helper_codi_eval_compare(actual, expect_key, opts)
      when is_atom(expect_key) and is_list(opts) do
    # any result to compare?
    case opts |> Keyword.has_key?(expect_key) do
      true ->
        expect = opts |> Keyword.get(expect_key)

        case expect == actual do
          true ->
            {:ok, actual}

          _ ->
            {:error,
             %ArgumentError{
               message:
                 "mismatch; expect_key #{inspect(expect_key)}; expect_tests: #{inspect(expect)}; actual: #{
                   inspect(actual)
                 }"
             }}
        end

      # nothing to do
      _ ->
        {:ok, actual}
    end
  end

  # returns {:ok, {result, texts, ast}} or {:error, error}.
  # the returned ast will be the reduced one used for eval i.e. after any transforms.
  # if no binding the result will be nil.

  def helper_codi_eval(ast, opts \\ [])

  def helper_codi_eval(nil, _opts) do
    {:ok, {nil, [""], nil}}
  end

  def helper_codi_eval(ast, opts) when is_list(opts) do
    opts = opts |> helper_codi_eval_opts_canon_keys!

    with {:ok, ast} <- ast |> helper_codi_transform(opts),
         {:ok, {actual_texts, ast}} <-
           ast |> helper_codi_eval_compare(@helper_opts_key_expect_texts, opts),
         {:ok, {actual_value, _actual_text, actual_form}} <-
           ast |> helper_codi_eval_compare(@helper_opts_key_binding, opts) do
      {:ok, {actual_value, actual_texts, actual_form}}
    else
      # if an error and matches the expected error then return {:ok, {actual_error, nil, nil}}
      {:error, error} ->
        case opts |> Keyword.has_key?(@helper_opts_key_expect_error) do
          true ->
            error
            |> helper_codi_eval_normalise_error
            |> helper_codi_eval_compare(@helper_opts_key_expect_error, opts)
            |> case do
              # expected error matches
              {:ok, actual_error} ->
                {:ok, {actual_error, nil, nil}}

              _ ->
                {:error, error}
            end

          # passthru
          _ ->
            {:error, error}
        end
    end
  end

  def helper_codi_transform(ast, opts \\ [])

  def helper_codi_transform(ast, []) do
    {:ok, ast}
  end

  def helper_codi_transform(ast, opts) do
    fun_transform =
      cond do
        Keyword.has_key?(opts, @helper_opts_key_transform) ->
          Keyword.get(opts, @helper_opts_key_transform)

        # default is to anonymise vars
        true ->
          &helper_codi_transform_anonymise_vars/1
      end
      |> list_wrap_flat_just
      |> case do
        [transform] ->
          transform

        transforms ->
          fn ast -> transforms |> Enum.reduce(ast, fn f, s -> f.(s) end) end
      end

    {:ok, fun_transform.(ast)}
  end

  def helper_codi_transform_anonymise_vars(ast) do
    ast
    |> Macro.postwalk(fn
      {name, [], mod} when is_atom(name) and is_atom(mod) -> Macro.var(name, nil)
      x -> x
    end)
  end

  @code_edits_beg [
    # dump too many leading or trailing space after \n
    {~r/\A\n\s\s*/s, "\n "},
    {~r/\n\s+\z/s, "\n"}
  ]

  @code_edits_mid [
    {~r/ case /, " case() "}
  ]

  @code_edits_fin [
    {~r/\-\>\n/, "-> "},
    {~r/\n\|\>/, " |>"},

    # dump too many leading or trailing space after \n
    {~r/\A\n\s\s*/s, "\n "},
    {~r/\n\s+\z/s, "\n"},

    # tidy front
    {~r/\A\(\n\s+/s, "("},

    # tidy back
    {~r/\n\s+\)\z/s, ")"}
  ]

  defp helper_codi_edits(code, edits) when is_binary(code) do
    edits
    |> Enum.reduce(code, fn {r, v}, s ->
      Regex.replace(r, s, v)
    end)
  end

  def helper_codi_clean_text(code)

  def helper_codi_clean_text(code) when is_binary(code) do
    text =
      code
      |> helper_codi_edits(@code_edits_beg)
      |> String.split("\n")
      |> Enum.reject(fn str -> String.length(str) == 0 end)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn str ->
        str |> helper_codi_edits(@code_edits_mid)
      end)
      |> Enum.reject(fn str -> String.length(str) == 0 end)
      |> Enum.join("\n ")
      |> (fn code ->
            code |> helper_codi_edits(@code_edits_fin)
          end).()

    {:ok, text}
  end

  def helper_codi_clean_text(code) do
    with {:ok, ast} <- code |> form_validate do
      ast |> Macro.to_string() |> helper_codi_clean_text
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_asts_clean_text(asts) do
    asts
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce_while([], fn ast, texts ->
      case ast |> helper_codi_clean_text do
        {:ok, text} -> {:cont, [text | texts]}
        {:error, %{__struct__: _}} = result -> {:halt, result}
      end
    end)
    |> case do
      {:error, %{__exception__: true}} = result -> result
      texts -> {:ok, texts |> Enum.reverse()}
    end
  end

  def helper_codi_compare(actual, expect) do
    with {:ok, actual_code} <- actual |> helper_codi_clean_text,
         {:ok, expect_code} <- expect |> helper_codi_clean_text do
      case Kernel.==(actual_code, expect_code) do
        true ->
          {:ok, actual}

        _ ->
          {:error,
           %ArgumentError{
             message:
               "expect_actual_mismatch; expect_code #{inspect(expect_code)}; actual_code #{
                 inspect(actual_code)
               }"
           }}
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_codi_compare!(actual_code, expect_code) do
    with {:ok, actual} <- helper_codi_compare(actual_code, expect_code) do
      actual
    else
      {:error, error} -> raise error
    end
  end

  def helper_codi_show_forms(forms, _opts \\ []) do
    with {:ok, forms} <- forms |> forms_validate do
      forms
      |> map_collate0_enum(&helper_codi_clean_text/1)
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_codi_show_forms!(forms, opts \\ []) do
    with {:ok, forms} <- forms |> helper_codi_show_forms(opts) do
      forms
    else
      {:error, error} -> raise error
    end
  end

  def helper_codi_format_forms(forms, _opts \\ []) do
    with {:ok, forms} <- forms |> forms_normalise do
      forms =
        forms
        |> Enum.flat_map(fn form ->
          form
          |> Macro.to_string()
          |> Code.format_string!()
          |> Enum.join()
          |> String.split("\n")
        end)

      {:ok, forms}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_codi_format_forms!(forms, opts \\ []) do
    with {:ok, forms} <- forms |> helper_codi_format_forms(opts) do
      forms
    else
      {:error, error} -> raise error
    end
  end

  def helper_codi_test_forms(forms, opts \\ []) do
    with {:ok, {_result, _text_forms, _reduced_form}} = result <- forms |> helper_codi_eval(opts) do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_codi_test_forms_result_texts(forms, opts \\ []) do
    with {:ok, {result, text_forms, _reduced_form}} <- forms |> helper_codi_test_forms(opts) do
      {:ok, {result, text_forms}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_codi_test_forms_texts(forms, opts \\ []) do
    with {:ok, {_result, text_forms, _reduced_form}} <- forms |> helper_codi_test_forms(opts) do
      {:ok, text_forms}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def helper_codi_test_forms!(forms, opts \\ []) do
    forms
    |> helper_codi_test_forms(opts)
    |> case do
      {:ok, {result, text_forms, _forms}} -> {result, text_forms}
      {:error, error} -> raise error
    end
  end

  defmacro __using__(_opts \\ []) do
    quote do
      use ExUnit.Case, async: false
      import PlymioCodiAstEvalHelper
    end
  end
end
