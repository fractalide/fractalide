{ lib
  , stdenv
  , git
  , purescript
  , purspkgsSupport
  , genName
  , unifySchema
}:

{ type ? ""}:

{ name ? null
  , src ? null
  , mods ? []
  , edges ? []
  , ...
} @ args:

let
  compName = if name == null then genName src else name;
  nearPureDeps = purspkgsSupport.pureDeps mods mods;
  unifiedSchema = unifySchema {
    name = compName;
    edges = edges;
    target = "rs";
  };
in stdenv.mkDerivation (args // rec {
  name = compName;
  inherit src mods;
  buildInputs = [purescript];
  pureDeps = lib.unique nearPureDeps ;
  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];
  buildPhase = args.buildPhase or ''
    echo "*********************************************************************"
    echo "****** building purescript ${type}: ${compName} "
    echo "*********************************************************************"
    ${purspkgsSupport.symlinkCalc (purspkgsSupport.pureDeps mods mods)}
    ${
      if type == "agent" then ''
        ln -s ${unifiedSchema}/edge_capnp.rs edge_capnp.rs
        mkdir ./output
        psc *.purs 'purelibs/*/src/**/*.purs' -o ./output
        #psc-bundle -o ./output output/**/src/*.js --module Main --main Main
      '' else ""}
  '';

  installPhase = ''
    mkdir -p $out
    cp -R ./output $out
  '';
})
