{ buffet
  , genName
  , unifyCapnpEdges
}:
let
  specialize = import ./specialize0.nix { inherit buffet genName unifyCapnpEdges;};
in
{
  fvm = specialize { fractalType = "fvm"; };
  agent = specialize { fractalType = "agent"; };
}
