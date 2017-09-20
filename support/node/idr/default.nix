{ buffet
  , genName
  , unifyCapnpEdges
}:
let
  build-idris-package = buffet.mods.idr.build-idris-package;
  specialize = import ./specialize.nix { inherit buffet build-idris-package genName unifyCapnpEdges;};
in
{
  fvm = specialize { fractalType = "fvm"; };
  agent = specialize { fractalType = "agent"; };
}
