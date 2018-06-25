defmodule Plymio.Codi.Attribute.Builder do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      @plymio_codi_builder_getset_namer :getset_namer
      @plymio_codi_builder_getset_default :getset_default
      @plymio_codi_builder_pattern_namer :pattern_namer
      @plymio_codi_builder_pattern_builder :pattern_builder
      @plymio_codi_builder_patterns :patterns
      @plymio_codi_builder_cpo :cpo

      @plymio_codi_builder_alias_getset_namer {@plymio_codi_builder_getset_namer, [:namer]}
      @plymio_codi_builder_alias_getset_default {@plymio_codi_builder_getset_default, [:default]}
      @plymio_codi_builder_alias_pattern_namer {@plymio_codi_builder_pattern_namer, []}
      @plymio_codi_builder_alias_pattern_builder {@plymio_codi_builder_pattern_builder,
                                                  [:builder]}
    end
  end
end
