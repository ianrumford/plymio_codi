ExUnit.start()

defmodule PlymioCodiHelperTest do
  defdelegate helper_codi_show_forms!(ast), to: PlymioCodiAstEvalHelper
  defdelegate helper_codi_show_forms!(ast, opts), to: PlymioCodiAstEvalHelper
  defdelegate helper_codi_format_forms!(ast), to: PlymioCodiAstEvalHelper
  defdelegate helper_codi_format_forms!(ast, opts), to: PlymioCodiAstEvalHelper
  defdelegate helper_codi_test_forms!(ast), to: PlymioCodiAstEvalHelper
  defdelegate helper_codi_test_forms!(ast, opts), to: PlymioCodiAstEvalHelper

  defmacro __using__(_opts \\ []) do
    quote do
      use ExUnit.Case, async: false
      import PlymioCodiHelperTest
    end
  end
end
