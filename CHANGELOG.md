# CHANGELOG

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


