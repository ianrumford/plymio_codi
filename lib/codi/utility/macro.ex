defmodule Plymio.Code.Utility.Macro do
  @moduledoc false

  # lifted from fontais v0.3.0

  defmacro def_custom_opts_maybe_put(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      for {fun_name, fun_key} <- opts do
        def unquote(fun_name)(opts, value) do
          opts_put_new(opts, unquote(fun_key), value)
        end
      end
    end
  end
end
