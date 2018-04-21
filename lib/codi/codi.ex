defmodule Plymio.Codi do
  @moduledoc ~S"""
  `Plymio.Codi` builds quoted forms for common code *patterns*.

  The `produce_codi/2` function generates the forms for the
  *patterns*. The `reify_codi/2` macro calls `produce_codi/2` and then
  compile the forms.

  ## Documentation Terms

  In the documentation below these terms, usually in *italics*, are used to mean the same thing.

  ### *opts*

  *opts* is a `Keyword` list.

  ### *form* and *forms*

  A *form* is a quoted form (`Macro.t`). A *forms* is a list of zero, one or more *form*s.

  ## Options (*opts*)

  The first argument to both of these functions is an *opts*.

  The canonical form of a *pattern* definition in the *opts* is the
  key `:pattern` with an *opts* value specific the to
  *pattern* e.g.

        [pattern: [pattern: :delegate, name: :fun_one, arity: 1, module: ModuleA]

  The value is referred to as the *cpo* below, short for *codi pattern opts*.

  All pattern definitions are normalised this format.

  However, for convenience, the key can be the *pattern* name
  (e.g. `:delegate`) and the value the (pre normalised) *cpo*:

        [delegate: [name: :fun_one, arity: 1, module: ModuleA]

  This example shows the code generated for the above:

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@doc(\"Delegated to `ModuleA.fun_one/1`\")",
       "defdelegate(fun_one(var1), to: ModuleA)"]

  Also, again for convenience, some *patterns* will normalise the
  value.  For example the `:doc` pattern normalises this:

      [doc: "This is a docstring"]

  into this:

      [pattern: [pattern: doc, doc: "This is a docstring"]

  The keys in the *cpo* have aliases. Note the aliases are
  pattern-specific. For examples `:args` is both an alias for
  `:spec_args` and `:fun_args`. Each pattern below lists its keys' aliases.

  ## Patterns

  There are a number of patterns, some having aliases, described below:

  | Pattern | Aliases |
  | :---  | :--- |
  | `:typespec_spec` | *:spec* |
  | `:doc` | |
  | `:since` | |
  | `:delegate` |  |
  | `:delegate_module` |  |
  | `:bang` |  |
  | `:bang_module` |  |
  | `:proxy` | *:proxies* |
  | `:form` | *:forms, :ast, :asts* |

  ### Pattern: *typespec_spec*

  The *typespec_spec* pattern builds a `@spec` form.

  Valid keys in the pattern opts are:

  | Key | Aliases |
  | :---       | :---            |
  | `:spec_name` | *:name :fun_name, :function_name* |
  | `:spec_args` | *:args, :fun_args, :function_args* |
  | `:spec_arity` | *:arity, :fun_arity, :function_arity* |
  | `:spec_result` | *:result, :fun_result, :function_result* |

  When an `:arity` is given, the `:spec_args` will all be `any`.

      iex> {:ok, {forms, _}} = [
      ...>   spec: [name: :fun1, arity: 1, result: :integer]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@spec(fun1(any) :: integer)"]

  The function's `args` can be given explicitly. Here a list of atoms
  are given which will be normalised to the equivalent type var. Note also
  the `:spec_result` is an explicit form.

      iex> spec_result = quote(do: binary | atom)
      iex> {:ok, {forms, _}} = [
      ...>   spec: [spec_name: :fun2, args: [:atom, :integer], spec_result: spec_result]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@spec(fun2(atom, integer) :: binary | atom)"]

  ### Pattern: *doc*

  The *doc* pattern builds a `@doc` form.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:fun_name` | *:name, :spec_name, :fun_name, :function_name* |
  | `:fun_args` | *:args, :spec_args, :fun_args, :function_args* |
  | `:fun_arity` | *:arity, :spec_arity, :fun_arity, :function_arity* |
  | `:fun_doc` | *:doc, :function_doc* |

  If the `:fun_doc` is `false`, documentation is turned off as expected:

      iex> {:ok, {forms, _}} = [
      ...>   doc: [doc: false]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@doc(false)"]

  The simplest `:fun_doc` is a string:

      iex> {:ok, {forms, _}} = [
      ...>   doc: [doc: "This is the docstring for fun1"]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@doc(\"This is the docstring for fun1\")"]

  For convenience, the `:fun_doc` can be `:bang` to generate a
  suitable docstring for a bang function. For this, the *cpo* must include the
  `:fun_name`, `:fun_args` or `:fun_arity`, and (optionally)
  `:fun_module`.

      iex> {:ok, {forms, _}} = [
      ...>   doc: [name: :fun_one, arity: 1, doc: :bang]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@doc(\"Bang function for `fun_one/1`\")"]

      iex> {:ok, {forms, _}} = [
      ...>   doc: [name: :fun_due, arity: 2, module: ModuleA, doc: :bang]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@doc(\"Bang function for `ModuleA.fun_due/2`\")"]

  Similarly, `:fun_doc` can be `:delegate` to generate a suitable
  docstring for a delegation.

      iex> {:ok, {forms, _}} = [
      ...>   doc: [name: :fun_due, arity: 2, doc: :delegate]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@doc(\"Delegated to `fun_due/2`\")"]

      iex> {:ok, {forms, _}} = [
      ...>   doc: [name: :fun_due, arity: 2, module: ModuleA, doc: :delegate]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@doc(\"Delegated to `ModuleA.fun_due/2`\")"]

  ### Pattern: *since*

  The *since* pattern builds a `@since` form.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:since` | |

  The value must be a string and is validated by `Version.parse/1`:

      iex> {:ok, {forms, _}} = [
      ...>   since: "1.7.9"
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["@since(\"1.7.9\")"]

      iex> {:error, error} = [
      ...>   since: "1.2.3.4.5"
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "since invalid, got: 1.2.3.4.5"

  ### Pattern: *delegate*

  The *delegate* pattern builds a `Kernel.defdelegate/2` call,
  together, optionally, with a `@doc`, `@since`, and/or `@spec`.

  Note the delegated mfa: `{module, function, arity}` is validated
  i.e. the `function` must exist in the `module` with the given
  `arity`.

  If `:delegate_doc` is not in the pattern opts, a default of
  `:delegate` is used.  (It can be disabled by explicily setting
  `:fun_doc` to `nil` - **not** `false`).

  Either `:fun_arity` or `:fun_args` is required.  If the former, the
  arguments in the delegate will be e.g. `var`.  If the `:fun_args` is
  given they will be used.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:delegate_module` | *:to, :module, :fun_mod, :fun_module, :function_module* |
  | `:delegate_name` | *:as* |
  | `:delegate_doc` | *:doc, :fun_doc, :function_doc* |
  | `:delegate_args` | *:args, :fun_args, :function_args* |
  | `:delegate_arity` | *:arity, :fun_arity, :function_arity* |
  | `:fun_name` | *:name, :function_name* |
  | `:spec_args` | |
  | `:spec_result` |*:result, :fun_result, :function_result* |
  | `:since` | |

  ## Examples

  A simple case. Note the automatically generated `:delegate`-format `@doc`.

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA],
      ...>   delegate: [name: :fun_due, arity: 2, module: ModuleA],
      ...>   delegate: [name: :fun_tre, arity: 3, module: ModuleA]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Delegated to `ModuleA.fun_one/1`\"",
       "defdelegate(fun_one(var1), to: ModuleA)",
       "@doc \"Delegated to `ModuleA.fun_due/2`\"",
       "defdelegate(fun_due(var1, var2), to: ModuleA)",
       "@doc \"Delegated to `ModuleA.fun_tre/3`\"",
       "defdelegate(fun_tre(var1, var2, var3), to: ModuleA)"]

  Here showing the auto-generated `@doc` disabled.

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA, doc: nil],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["defdelegate(fun_one(var1), to: ModuleA)"]

  This example shows explicit function arguments (`:args`) being given:

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, args: :opts, module: ModuleA, doc: nil],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["defdelegate(fun_one(opts), to: ModuleA)"]

  Delegating to a different function name (`:as`):

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_3, as: :fun_tre, args: [:opts, :key, :value], module: ModuleA, doc: nil],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["defdelegate(fun_3(opts, key, value), to: ModuleA, as: :fun_tre)"]

  Here a `@doc`, `@since`, and `@spec` are generated.  Note in the first
  example the `:spec_args` are explicily given as well as the
  `:spec_result`.  In the second no `:spec_args` are given and the
  arity used.

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA,
      ...>   since: "1.7.9", spec_args: :integer, spec_result: :tuple],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Delegated to `ModuleA.fun_one/1`\"",
       "@since \"1.7.9\"",
       "@spec fun_one(integer) :: tuple",
       "defdelegate(fun_one(var1), to: ModuleA)"]

      iex> {:ok, {forms, _}} = [
      ...>   delegate: [name: :fun_one, arity: 1, module: ModuleA,
      ...>   since: "1.7.9", spec_result: :tuple],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Delegated to `ModuleA.fun_one/1`\"",
       "@since \"1.7.9\"",
       "@spec fun_one(any) :: tuple",
       "defdelegate(fun_one(var1), to: ModuleA)"]

  Showing validation of the `mfa`:

      iex> {:error, error} = [
      ...>   delegate: [name: :fun_one, arity: 2, module: ModuleZ],
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "mfa {ModuleZ, :fun_one, 2} module unknown"

      iex> {:error, error} = [
      ...>   delegate: [name: :fun_1, arity: 2, module: ModuleA],
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "mfa {ModuleA, :fun_1, 2} function unknown"

      iex> {:error, error} = [
      ...>   delegate: [name: :fun_one, arity: 2, module: ModuleA],
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "mfa {ModuleA, :fun_one, 2} arity unknown"

  ### Pattern: *delegate_module*

  The *delegate_module* pattern builds a `Kernel.defdelegate/2` call
  for one or more functions in a module. As with `:delegate` a `@doc` and/or `@since`
  can be generated at the same time.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:delegate_module` | *:to :module, :fun_module, :fun_mod, :function_module* |
  | `:delegate_doc` | *:doc, :fun_doc, :function_doc* |
  | `:take` |  |
  | `:drop` |  |
  | `:filter` |  |
  | `:reject` |  |
  | `:since` | |

  To determine which functions to delegate, the "function v arity"
  (*fva*) for the module is first obtained by calling e.g. `ModuleA.__info__(:functions)`.

  The *delegate options* can include `:take`, `:drop`, `:filter` or
  `:reject` keys to "edit" the *fva*..

  The first two take zero, one or more function names
  and are used in a call to e.g. `Keyword.take/2` with the *fva*.

  The second two keys require an arity 1 function (predicate) passed a
  `{fun,arity}` tuple, returning `true` or `false` and is used with e.g. `Enum.filter/2`.

  > Note the fva edits are applied in order of occurence so `:take`-ing a function already `:reject`-ed will do nothing.

  Here all functions in the module (`ModuleA`) are wanted with auto-generated `@doc` and `@since`:

      iex> {:ok, {forms, _}} = [
      ...>   delegate_module: [module: ModuleA, since: "1.7.9"],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Delegated to `ModuleA.fun_due/2`\"",
       "@since \"1.7.9\"",
       "defdelegate(fun_due(var1, var2), to: ModuleA)",
       "@doc \"Delegated to `ModuleA.fun_one/1`\"",
       "@since \"1.7.9\"",
       "defdelegate(fun_one(var1), to: ModuleA)",
       "@doc \"Delegated to `ModuleA.fun_tre/3`\"",
       "@since \"1.7.9\"",
       "defdelegate(fun_tre(var1, var2, var3), to: ModuleA)"]

  Here arity 2 funs are selected, and `@doc` is disabled.

      iex> {:ok, {forms, _}} = [
      ...>   delegate_module: [
      ...>     module: ModuleA, doc: nil,
      ...>     filter: fn {_fun,arity} -> arity == 3 end],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["defdelegate(fun_tre(var1, var2, var3), to: ModuleA)"]

  ### Pattern: *bang*
  The *bang* pattern builds a bang function, together, optionally, with a `@doc`, `@since` and/or `@spec`.

  The bang function assumes the non-bang function returns either
  `{:ok, value}` or `{:error, error}`, returning `value` or raising
  `error`.

  Note if the real function is in another module, the real mfa `{module, function, arity}` is validated i.e. the `function` must exist in the `module` with the given `arity`.

  If `:fun_doc` is not in the pattern opts, a default of `:bang` is used.
  (It can be disabled by explicitly setting `:fun_doc` to `nil`)

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:bang_module` | *:module, :fun_mod, :bang_module, :function_module* |
  | `:bang_name` | *:name, :fun_name, :function_name* |
  | `:bang_args` | *:args, :fun_args, :function_args* |
  | `:bang_arity` | *:arity, :fun_arity, :function_arity* |
  | `:bang_doc` | *:doc, :fun_doc, :function_doc* |
  | `:spec_args` | |
  | `:spec_result` |*:result, :fun_result, :function_result* |
  | `:since` | |

  Here is the common case of a bang function for a function in the
  same module. Note the automatically generated `:bang`-format `@doc`
  and explicitly specified `@since`:

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, arity: 3, since: "1.7.9"]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Bang function for `fun_tre/3`\"",
       "@since \"1.7.9\"",
       "def(fun_tre!(var1, var2, var3)) do",
       "  case(fun_tre(var1, var2, var3)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  Here the other function is in a different module(`ModuleA`):

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, arity: 3, to: ModuleA, since: "1.7.9"]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_tre/3`\"",
       "@since \"1.7.9\"",
       "def(fun_tre!(var1, var2, var3)) do",
       "  case(ModuleA.fun_tre(var1, var2, var3)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  The `:fun_args` can be supplied to improve the definition. Note the `:fun_doc` is set to `false`.

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, args: [:x, :y, :z], to: ModuleA, fun_doc: false]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc false", "def(fun_tre!(x, y, z)) do",
       "  case(ModuleA.fun_tre(x, y, z)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  Similary, if the *cpo* contains a `:spec_result` key, a `@spec` will
  be generated. The second example has an explicit `:spec_args`

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, args: [:x, :y, :z], module: ModuleA, result: :tuple]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_tre/3`\"",
       "@spec fun_tre!(any, any, any) :: tuple",
       "def(fun_tre!(x, y, z)) do",
       "  case(ModuleA.fun_tre(x, y, z)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

      iex> {:ok, {forms, _}} = [
      ...>   bang: [as: :fun_tre, args: [:x, :y, :z], module: ModuleA,
      ...>          spec_args: [:integer, :binary, :atom], result: :tuple]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_tre/3`\"",
       "@spec fun_tre!(integer, binary, atom) :: tuple",
       "def(fun_tre!(x, y, z)) do",
       "  case(ModuleA.fun_tre(x, y, z)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  ### Pattern: *bang_module*

  The *bang_module* pattern builds a bang function for one or more
  functions in a module. As with `:bang` a `@doc` or `@since` can be generated at
  the same time.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:bang_module` | *:to, :module, :fun_mod, :fun_module, :function_module* |
  | `:bang_doc` | *:doc, :fun_doc, :function_doc* |
  | `:take` |  |
  | `:drop` |  |
  | `:filter` |  |
  | `:reject` |  |
  | `:since` | |

  Here a bang function will be generated for all the functions in the module.

      iex> {:ok, {forms, _}} = [
      ...>   bang_module: [module: ModuleA],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_due/2`\"",
       "def(fun_due!(var1, var2)) do",
       "  case(ModuleA.fun_due(var1, var2)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end",
       "@doc \"Bang function for `ModuleA.fun_one/1`\"",
       "def(fun_one!(var1)) do", "  case(ModuleA.fun_one(var1)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end",
       "@doc \"Bang function for `ModuleA.fun_tre/3`\"",
       "def(fun_tre!(var1, var2, var3)) do",
       "  case(ModuleA.fun_tre(var1, var2, var3)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  In the same way as `:delegate_module` the functions can be selected
  using e.g. `:take`. Here `:since` is also given.

      iex> {:ok, {forms, _}} = [
      ...>   bang_module: [module: ModuleA, take: :fun_due, since: "1.7.9"],
      ...> ] |> produce_codi
      ...> forms |> helper_codi_format_forms!
      ["@doc \"Bang function for `ModuleA.fun_due/2`\"",
       "@since \"1.7.9\"",
       "def(fun_due!(var1, var2)) do",
       "  case(ModuleA.fun_due(var1, var2)) do",
       "    {:ok, value} ->",
       "      value",
       "",
       "    {:error, error} ->",
       "      raise(error)",
       "  end",
       "end"]

  ### Pattern: *proxy*

  The *proxy* pattern looks up a *form* or *forms* in a dictionary called the
  *vekil*: The *proxy* is the *key* and the *form* / *forms* the value.

  The *vekil* must be provided else an error result will returned.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:proxy_name` | *:proxy* |

  A simple case.

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :add_1,
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["def(add_1(x)) do\n x + 1\n end"]

  If the *proxy* is not found, or there is no *vekil*, or the *vekil* is invalid, an error will be raised.

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...> }
      ...> {:error, error} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :add_11,
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "proxy not found, got: :add_11"

      iex> {:error, error} = [
      ...>   proxy: :add_11,
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "vekil missing"

      iex> vekil_dict = %{
      ...>    # a map is not a valid form
      ...>    add_1: %{a: 1},
      ...> }
      ...> {:error, error} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :add_1,
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "vekil invalid, got: forms invalid, got invalid indices: [0]"

  Multiple proxies can be given:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    sqr_x: quote(do: def(sqr_x(x), do: x * x)),
      ...>    sub_1: quote(do: def(sub_1(x), do: x - 1)),
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxies: [:add_1, :sqr_x, :sub_1]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["def(add_1(x)) do\n x + 1\n end",
       "def(sqr_x(x)) do\n x * x\n end",
       "def(sub_1(x)) do\n x - 1\n end"]

  The *proxy* can be a list of other proxies:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    sqr_x: quote(do: def(sqr_x(x), do: x * x)),
      ...>    sub_1: quote(do: def(sub_1(x), do: x - 1)),
      ...>    all: [:add_1, :sqr_x, :sub_1],
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :all
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["def(add_1(x)) do\n x + 1\n end",
       "def(sqr_x(x)) do\n x * x\n end",
       "def(sub_1(x)) do\n x - 1\n end"]

  When the *proxy* is a list of proxies, infinite loops are caught:

      iex> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    sqr_x: quote(do: def(sqr_x(x), do: x * x)),
      ...>    sub_1: quote(do: def(sub_1(x), do: x - 1)),
      ...>    all_loop: [:add_1, :sqr_x, :sub_1, :all_loop],
      ...> }
      ...> {:error, error} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: :all_loop
      ...> ] |> produce_codi
      ...> error |> Exception.message
      "proxy seen before, got: :all_loop"

  There is support to edit the *proxy* *forms* using
  `Macro.postwalk/2`. This example changes all the `x` vars to `a`
  vars.

      iex> postwalk_fun = fn
      ...>   {:x, [], m} -> {:a, [], m}
      ...>   x -> x
      ...> end
      ...> vekil_dict = %{
      ...>    add_1: quote(do: def(add_1(x), do: x + 1)),
      ...>    sqr_x: quote(do: def(sqr_x(x), do: x * x)),
      ...>    sub_1: quote(do: def(sub_1(x), do: x - 1)),
      ...>    all: [:add_1, :sqr_x, :sub_1],
      ...> }
      ...> {:ok, {forms, _}} = [
      ...>   vekil: vekil_dict,
      ...>   proxy: [proxy: :all, postwalk: postwalk_fun]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["def(add_1(a)) do\n a + 1\n end",
       "def(sqr_x(a)) do\n a * a\n end",
       "def(sub_1(a)) do\n a - 1\n end"]

  ### Pattern: *form*

  The *form* pattern is a convenience to embed arbitrary code.

  Valid keys in the *cpo* are:

  | Key | Aliases |
  | :---  | :--- |
  | `:form` | *:forms, :ast, :asts* |

      iex> {:ok, {forms, _}} = [
      ...>    form: quote(do: def(add_1(x), do: x + 1)),
      ...>    ast: quote(do: def(sqr_x(x), do: x * x)),
      ...>    forms: [
      ...>       quote(do: def(sub_1(x), do: x - 1)),
      ...>       quote(do: def(sub_2(x), do: x - 2)),
      ...>      ]
      ...> ] |> produce_codi
      ...> forms |> helper_codi_show_forms!
      ["def(add_1(x)) do\n x + 1\n end",
       "def(sqr_x(x)) do\n x * x\n end",
       "def(sub_1(x)) do\n x - 1\n end",
       "def(sub_2(x)) do\n x - 2\n end"]

  """

  require Plymio.Fontais.Vekil, as: PFW
  require Plymio.Fontais.Option, as: PFO
  use Plymio.Fontais.Attribute
  use Plymio.Codi.Attribute

  @codi_opts [
    {@plymio_fontais_key_vekil, Plymio.Fontais.Codi.__vekil__()}
  ]

  import Plymio.Fontais.Guard,
    only: [
      is_value_set: 1,
      is_value_unset: 1,
      is_value_unset_or_nil: 1
    ]

  import Plymio.Fontais.Option,
    only: [
      opzioni_flatten: 1,
      opts_create_aliases_dict: 1
    ]

  import Plymio.Fontais.Vekil,
    only: [
      normalise_vekil: 1
    ],
    warn: false

  import Plymio.Codi.Utility.Dispatch,
    only: [
      validate_pattern_dispatch_vector: 1
    ]

  import Plymio.Codi.Utility,
    only: [
      validate_module_dict: 1,
      validate_fun_module: 1
    ],
    warn: false

  import Plymio.Codi.Utility.GetSet,
    only: [
      cpo_get_status: 2,
      cpo_get_patterns: 1,
      cpo_normalise_forms: 1
    ]

  import Plymio.Funcio.Enum.Map.Collate,
    only: [
      map_collate0_enum: 2
    ]

  @plymio_codi_pattern_dicts @plymio_fontais_the_unset_value

  @plymio_codi_pattern_normalisers %{
    @plymio_codi_pattern_form => &Plymio.Codi.Pattern.Various.cpo_pattern_form_normalise/1,
    @plymio_codi_pattern_since => &Plymio.Codi.Pattern.Various.cpo_pattern_since_normalise/1,
    @plymio_codi_pattern_typespec_spec =>
      &Plymio.Codi.Pattern.Typespec.Spec.cpo_pattern_type_normalise/1,
    @plymio_codi_pattern_doc => &Plymio.Codi.Pattern.Doc.cpo_pattern_doc_normalise/1,
    @plymio_codi_pattern_bang => &Plymio.Codi.Pattern.Bang.cpo_pattern_bang_normalise/1,
    @plymio_codi_pattern_bang_module =>
      &Plymio.Codi.Pattern.Bang.cpo_pattern_bang_module_normalise/1,
    @plymio_codi_pattern_proxy => &Plymio.Codi.Pattern.Proxy.cpo_pattern_proxy_normalise/1,
    @plymio_codi_pattern_delegate =>
      &Plymio.Codi.Pattern.Delegate.cpo_pattern_delegate_normalise/1,
    @plymio_codi_pattern_delegate_module =>
      &Plymio.Codi.Pattern.Delegate.cpo_pattern_delegate_module_normalise/1
  }

  @plymio_codi_pattern_express_dispatch %{
    @plymio_codi_pattern_typespec_spec => &Plymio.Codi.Pattern.Typespec.Spec.express_pattern/3,
    @plymio_codi_pattern_doc => &Plymio.Codi.Pattern.Doc.express_pattern/3,
    @plymio_codi_pattern_bang => &Plymio.Codi.Pattern.Bang.express_pattern/3,
    @plymio_codi_pattern_bang_module => &Plymio.Codi.Pattern.Bang.express_pattern/3,
    @plymio_codi_pattern_delegate => &Plymio.Codi.Pattern.Delegate.express_pattern/3,
    @plymio_codi_pattern_delegate_module => &Plymio.Codi.Pattern.Delegate.express_pattern/3,
    @plymio_codi_pattern_proxy => &Plymio.Codi.Pattern.Proxy.express_pattern/3,
    @plymio_codi_pattern_form => &Plymio.Codi.Pattern.Various.express_pattern/3,
    @plymio_codi_pattern_since => &Plymio.Codi.Pattern.Various.express_pattern/3
  }

  @plymio_codi_stage_dispatch [
    {@plymio_codi_stage_normalise, &__MODULE__.Stage.Normalise.produce_stage/1},
    {@plymio_codi_stage_express, &__MODULE__.Stage.Express.produce_stage/1},
    {@plymio_codi_stage_review, &__MODULE__.Stage.Review.produce_stage/1}
  ]

  @plymio_codi_kvs_verb [
    # struct
    @plymio_codi_field_alias_snippets,
    @plymio_codi_field_alias_stage_dispatch,
    @plymio_codi_field_alias_patterns,
    @plymio_codi_field_alias_pattern_dicts,
    @plymio_codi_field_alias_pattern_normalisers,
    @plymio_codi_field_alias_pattern_express_dispatch,
    @plymio_codi_field_alias_forms,
    @plymio_codi_field_alias_vekil,
    @plymio_codi_field_alias_module_fva_dict,
    @plymio_codi_field_alias_module_doc_dict,

    # virtual
    @plymio_codi_pattern_alias_typespec_spec,
    @plymio_codi_pattern_alias_doc,
    @plymio_codi_pattern_alias_since,
    @plymio_codi_pattern_alias_bang,
    @plymio_codi_pattern_alias_bang_module,
    @plymio_codi_pattern_alias_delegate,
    @plymio_codi_pattern_alias_delegate_module,
    @plymio_codi_key_alias_pattern,
    @plymio_codi_pattern_alias_proxy,
    @plymio_codi_pattern_alias_form
  ]

  @plymio_codi_dict_verb @plymio_codi_kvs_verb
                         |> opts_create_aliases_dict

  @plymio_codi_defstruct [
    {@plymio_codi_field_snippets, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_stage_dispatch, @plymio_codi_stage_dispatch},
    {@plymio_codi_field_patterns, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_pattern_express_dispatch, @plymio_codi_pattern_express_dispatch},
    {@plymio_codi_field_pattern_dicts, @plymio_codi_pattern_dicts},
    {@plymio_codi_field_pattern_normalisers, @plymio_codi_pattern_normalisers},
    {@plymio_codi_field_forms, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_vekil, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_module_fva_dict, @plymio_fontais_the_unset_value},
    {@plymio_codi_field_module_doc_dict, @plymio_fontais_the_unset_value}
  ]

  defstruct @plymio_codi_defstruct

  @type t :: %__MODULE__{}
  @type kv :: Plymio.Fontais.kv()
  @type opts :: Plymio.Fontais.opts()
  @type error :: Plymio.Fontais.error()
  @type result :: Plymio.Fontais.result()
  @type form :: Plymio.Fontais.form()
  @type forms :: Plymio.Fontais.forms()

  @doc false

  def update_canonical_opts(opts, dict \\ @plymio_codi_dict_verb) do
    opts |> PFO.opts_canonical_keys(dict)
  end

  [
    :doc_false,
    :def_new,
    :doc_false,
    :def_new!,
    :doc_false,
    :def_update,
    :doc_false,
    :def_update!,
    :defp_update_field_header,
    :defp_update_field_proxy_normalise
  ]
  |> PFW.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           :proxy_field -> @plymio_codi_field_module_fva_dict
           {:proxy_field_normalise, ctx, args} -> {:validate_module_dict, ctx, args}
           :PRODUCESTAGESTRUCT -> __MODULE__
           x -> x
         end}
      ]
  )

  [
    :defp_update_field_proxy_normalise
  ]
  |> PFW.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           :proxy_field -> @plymio_codi_field_vekil
           {:proxy_field_normalise, ctx, args} -> {:normalise_vekil, ctx, args}
           :PRODUCESTAGESTRUCT -> __MODULE__
           x -> x
         end}
      ]
  )

  [
    :defp_update_field_proxy_validate_opzioni
  ]
  |> PFW.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           :proxy_field -> @plymio_codi_field_patterns
           :PRODUCESTAGESTRUCT -> __MODULE__
           x -> x
         end}
      ]
  )

  defp update_field(%__MODULE__{} = state, {k, v})
       when k in @plymio_codi_pattern_types or k == @plymio_codi_key_pattern do
    state |> add_snippets({k, v})
  end

  defp update_field(%__MODULE__{} = state, {k, v})
       when k == @plymio_codi_field_pattern_express_dispatch do
    with {:ok, dispatch_vector} <- v |> validate_pattern_dispatch_vector do
      state |> struct!([{@plymio_codi_field_pattern_express_dispatch, dispatch_vector}])
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  [
    :defp_update_field_passthru
  ]
  |> PFW.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           :proxy_field -> @plymio_codi_field_snippets
           :PRODUCESTAGESTRUCT -> __MODULE__
           x -> x
         end}
      ]
  )

  @plymio_codi_defstruct_updaters @plymio_codi_defstruct

  for {name, _} <- @plymio_codi_defstruct_updaters do
    update_fun = "update_#{name}" |> String.to_atom()

    @doc false
    def unquote(update_fun)(%__MODULE__{} = state, value) do
      state |> update([{unquote(name), value}])
    end
  end

  @plymio_codi_defstruct_reseters @plymio_codi_defstruct
                                  |> Keyword.take([
                                    @plymio_codi_field_snippets,
                                    @plymio_codi_field_patterns
                                  ])

  for {name, _} <- @plymio_codi_defstruct_reseters do
    reset_fun = "reset_#{name}" |> String.to_atom()

    @doc false
    def unquote(reset_fun)(%__MODULE__{} = state, value \\ @plymio_fontais_the_unset_value) do
      state |> update([{unquote(name), value}])
    end
  end

  defp add_snippets(state, patterns)

  defp add_snippets(%__MODULE__{@plymio_codi_field_snippets => snippets} = state, new_snippets) do
    snippets
    |> case do
      x when is_value_unset(x) ->
        state |> update_snippets(List.wrap(new_snippets))

      x when is_list(x) ->
        state |> update_snippets(x ++ List.wrap(new_snippets))
    end
  end

  [
    :doc_false,
    :def_produce
  ]
  |> PFW.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           {:express, ctx, args} -> {:produce_recurse, ctx, args}
           :PRODUCESTAGESTRUCT -> __MODULE__
           x -> x
         end}
      ]
  )

  @doc false

  @since "0.1.0"

  @spec produce_recurse(t) :: {:ok, {opts, t}} | {:error, error}

  def produce_recurse(codi)

  def produce_recurse(%__MODULE__{@plymio_codi_field_snippets => snippets} = state)
      when is_value_set(snippets) do
    with {:ok, {_product, %__MODULE__{} = state}} <-
           state |> __MODULE__.Stage.Normalise.normalise_snippets(),
         {:ok, %__MODULE__{} = state} = state |> reset_snippets,
         {:ok, {_product, %__MODULE__{}}} = result <- state |> produce_recurse do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def produce_recurse(%__MODULE__{} = state) do
    with {:ok, {product, state}} <- state |> produce_stages,
         {:ok, cpos} <- product |> cpo_get_patterns do
      # unless all cpos have status "done" need to recurse. default is done.
      cpos
      |> map_collate0_enum(fn cpo -> cpo |> cpo_get_status(@plymio_codi_status_done) end)
      |> case do
        {:error, %{__struct__: _}} = result ->
          result

        {:ok, statuses} ->
          statuses
          |> Enum.all?(fn status -> status == @plymio_codi_status_done end)
          |> case do
            true ->
              {:ok, {product, state}}

            _ ->
              state |> produce_recurse
          end
      end
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  @since "0.1.0"

  @spec produce_codi(any, any) :: {:ok, {forms, t}} | {:error, error}

  def produce_codi(opts, codi_or_opts \\ [])

  def produce_codi(opts, %__MODULE__{} = state) do
    # need to reset patterns to stop infinite recursion
    with {:ok, %__MODULE__{} = state} <- state |> reset_patterns,
         {:ok, %__MODULE__{} = state} <- state |> reset_snippets,
         {:ok, %__MODULE__{} = state} <- state |> update(opts),
         {:ok, {opts_patterns, %__MODULE__{} = state}} <- state |> produce,
         {:ok, opzionis} <- opts_patterns |> cpo_get_patterns,
         {:ok, cpo} <- opzionis |> opzioni_flatten,
         {:ok, forms} <- cpo |> cpo_normalise_forms do
      {:ok, {forms, state}}
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  def produce_codi(opts, new_opts) do
    with {:ok, %__MODULE__{} = state} <- new_opts |> new,
         {:ok, _} = result <- opts |> produce_codi(state),
         true <- true do
      result
    else
      {:error, %{__exception__: true}} = result -> result
    end
  end

  defmacro reify_codi(opts \\ [], other_opts \\ []) do
    module = __CALLER__.module

    quote bind_quoted: [opts: opts, other_opts: other_opts, module: module] do
      with {:ok, {forms, _}} <- opts |> Plymio.Codi.produce_codi(other_opts),
           {:ok, forms} <- forms |> Plymio.Fontais.Form.forms_normalise() do
        forms
        |> Code.eval_quoted([], __ENV__)
      else
        {:error, %{__exception__: true} = error} -> raise error
      end
    end
  end

  [
    :doc_false,
    :def_produce_stages
  ]
  |> PFW.reify_proxies(
    @codi_opts ++
      [
        {@plymio_fontais_key_postwalk,
         fn
           :produce_stage_field -> @plymio_codi_field_stage_dispatch
           :PRODUCESTAGESTRUCT -> __MODULE__
           x -> x
         end}
      ]
  )
end

defimpl Inspect, for: Plymio.Codi do
  use Plymio.Codi.Attribute

  import Plymio.Fontais.Guard,
    only: [
      is_value_unset: 1
    ]

  def inspect(
        %Plymio.Codi{
          @plymio_codi_field_vekil => vekil,
          @plymio_codi_field_snippets => snippets,
          @plymio_codi_field_patterns => patterns,
          @plymio_codi_field_forms => forms
        },
        _opts
      ) do
    vekil_telltale =
      vekil
      |> case do
        x when is_value_unset(x) -> "V=X"
        x when is_map(x) -> "V=#{x |> map_size}"
        _ -> "V=?"
      end

    snippets_telltale =
      snippets
      |> case do
        x when is_value_unset(x) -> "S=X"
        x when is_list(x) -> "S=#{x |> length}"
        _ -> "S=?"
      end

    patterns_telltale =
      patterns
      |> case do
        x when is_value_unset(x) ->
          "P=X"

        x when is_list(x) ->
          [
            "P=#{x |> length}/(",
            x
            |> Stream.map(fn opts ->
              opts
              |> Keyword.new()
              |> Keyword.get(@plymio_codi_key_pattern)
              |> to_string
            end)
            |> Enum.join(","),
            ")"
          ]
          |> Enum.join()
      end

    forms_telltale =
      forms
      |> case do
        x when is_value_unset(x) ->
          "F=X"

        x when is_list(x) ->
          "F=#{x |> length}"
      end

    codi_telltale =
      [
        snippets_telltale,
        patterns_telltale,
        forms_telltale,
        vekil_telltale
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join("; ")

    "CODI(#{codi_telltale})"
  end
end
