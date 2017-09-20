{ buffet
  , build-idris-package
  , genName
  , unifyCapnpEdges
}:

{ fractalType ? ""}:

{ name ? null
  , src ? null
  , mods ? []
  , capnp_edges ? []
  , edges ? []
  , ipkg ? ""
  , ...
} @ args:

let
  compName = if name == null then genName src else name;
  unifyIdrisEdges = import ./unifyIdrisEdges.nix { inherit buffet; };
  unifiedIdrisEdges = if edges != [] then unifyIdrisEdges {
    name = compName;
    edges = edges;
  } else [];
in build-idris-package (args // rec {
  name = compName;
  inherit src unifiedIdrisEdges;
  prePatch = ''
    if [ -e agent.ipkg ]; then
      substituteInPlace agent.ipkg --replace nix_replace_me ${compName}
    fi
  '';
  propagatedBuildInputs = mods;
})
