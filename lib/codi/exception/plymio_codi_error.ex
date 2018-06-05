defmodule Plymio.Codi.Error do
  @moduledoc false

  require Plymio.Vekil.Utility, as: VEKILUTIL
  use Plymio.Vekil.Attribute

  @codi_opts [
    {@plymio_vekil_key_vekil, Plymio.Vekil.Codi.__vekil__()}
  ]

  :defexception_package
  |> VEKILUTIL.reify_proxies(@codi_opts)
end
