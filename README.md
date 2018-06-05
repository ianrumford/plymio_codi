# README

**plymio\_codi**: Generating Quoted Forms for Common Code Patterns

`Plymio.Codi` is a tool that generates common code (quoted forms) patterns
such as bang functions, delegations, *code sharing* , etc.

The *code sharing* (*proxy*) patterns use `Plymio.Vekil` to allow
"snippets" of code to be pulled into modules for compilation together
for e.g. function clauses, pattern matching, etc.

## Installation

Add **plymio\_codi** to your list of dependencies in *mix.exs*:

    def deps do
      [{:plymio_codi, "~> 0.2.0"}]
    end

## Examples

See the examples in the [API Reference](<https://hexdocs.pm/plymio_codi/api-reference.html>).
