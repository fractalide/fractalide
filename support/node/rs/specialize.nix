{ buffet
  , buildRustCrate
  , unifyCapnpEdges
  , unifyRustEdges
  , transformNodeIntoCrate
  , genName
}:
{ name ? null
  , src ? null
  , osdeps ? []
  , mods ? []
  , capnp_edges ? []
  , edges ? []
  , postInstall ? ""
  , ... } @ args:
let
  compName = if name == null then genName src else name;
  unifiedRustEdges = if edges != [] then unifyRustEdges {
    name = compName;
    edges = edges;
  } else [];
  unifiedCapnpEdges = unifyCapnpEdges {
    name = compName;
    edges = capnp_edges;
    target = "rs";
  };
  crate = transformNodeIntoCrate {
    name = compName;
    src = src;
    version = "0.0.0";
    inherit unifiedCapnpEdges unifiedRustEdges postInstall;
  };
  in
  buildRustCrate {
    crateName = crate.crateName;
    version = crate.version;
    src = crate.out;
    release = buffet.release;
    verbose = buffet.verbose;
    dependencies = mods;
    buildInputs = osdeps;
    plugin = true;
    postInstall = "ln -s $out/lib/*.so $out/lib/libagent.so";
  }
