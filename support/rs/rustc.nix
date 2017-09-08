{ buffet
  , rust
  , crates
  , mkRustCrate
  , unifySchema
  , genName
}:

{ fractalType ? ""}:

{ name ? null
  , src ? null
  , osdeps ? []
  , mods ? []
  , edges ? []
  , configurePhase ? ""
  , ... } @ args:

let
  compName = if name == null then genName src else name;
  unifiedSchema = unifySchema {
    name = compName;
    edges = edges;
    target = "rs";
  };
  crate = mkRustCrate {
    unifiedSchema = unifiedSchema;
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
  };
in
  crate
