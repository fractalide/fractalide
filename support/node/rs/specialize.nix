{ buffet
  , rust
  , crates
  , build-rust-package
  , unifyCapnpEdges
  , genName
}:

{ fractalType ? ""}:

{ name ? null
  , src ? null
  , osdeps ? []
  , mods ? []
  , capnp_edges ? []
  , edges ? []
  , configurePhase ? ""
  , ... } @ args:
let
  compName = if name == null then genName src else name;
  unifyRustEdges = import ./unifyRustEdges.nix { inherit buffet; };
  unifiedRustEdges = if edges != [] then unifyRustEdges {
    name = compName;
    edges = edges;
  } else [];
  unifiedCapnpEdges = unifyCapnpEdges {
    name = compName;
    edges = capnp_edges;
    target = "rs";
  };
in
  build-rust-package {
    unifiedCapnpEdges = unifiedCapnpEdges;
    unifiedRustEdges = unifiedRustEdges;
    buildInputs = osdeps;
    crateName = compName;
    version = "";
    libPath = "lib.rs";
    dependencies = mods;
    fractalType = fractalType;
    src = src;
    features = [];
    configurePhase = configurePhase;
    release = buffet.release;
    verbose = buffet.verbose;
  }
