# CHANGELOG

## v0.3.0

### Bug Fixes

Minor fixes.

### Documentation

The details and examples for each pattern are now broken out into the
pattern modules and should make the documenation easier to navigate.

### Editing Generated Forms

The generated forms can be edited at the pattern level or "globally"
using a `:forms_edit` `Keyword` in the *codi pattern opts* (*cpo*).
The *form* pattern examples in `Plymio.Codi.Pattern.Other` show how
to do this.

### New *use* Macro

There is now a `use` macro that should be called in modules using the package.

### New *deprecate* Pattern

The `@deprecate` module attribute is now supported.

### New *query* Patterns

The new *query* patterns support building query functions
(e.g. `myfun?(arg)`) using a base function (e.g. `myfun(arg)`).  When
the base function returns `{:ok, _}`, the query function returns
`true`. Otherwise the query function returns `false.`See
`Plymio.Codi.Pattern.Query` for details and examples.

### New *struct* Patterns

The new *struct* patterns generate functions to transform a module's
*struct* (`Kernel.defstruct/1`). See `Plymio.Codi.Pattern.Struct` for
details and examples.

## v0.2.0

### Vekils are now managed by `Plymio.Vekil`

The *vekil* used by the *proxy* patterns is now managed by the
`Plymio.Vekil` protocol and package.

Previously a *vekil* was treated as read-only but now can be updated
using e.g. the `proxy_put` pattern.  So, for example, the doc proxy
(e.g. `:state_def_new_doc`) in a composite proxy (e.g. `:state_def_new` - see
`Plymio.Fontais.Codi.State`) can be selectively updated.

Patterns have been added to support most of the `Plymio.Vekil` protocol methods - see the
examples.

### Editing Pattern Forms

Most patterns generate quoted forms. Pattern-specific forms, or all forms, can be edited
by giving a `:forms_edit` key with `Keyword` value understood by
`Plymio.Fontais.Form.forms_edit/2`.  See the examples.

### Internal Changes

`Plymio.Codi.GetSet` has been renamed `Plymio.Codi.CPO` to highlight
its role in managing (mostly) `cpo` (*codi pattern opts*).

## v0.1.0

`Plymio.Codi` is a tool to build common code (quote forms) patterns
such as bang funcions, delegations, etc.


