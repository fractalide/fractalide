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
  , osdeps ? []
  , edges ? []
  , ...
} @ args:

let
  compName = if name == null then genName src else name;
  unifiedSchema = unifySchema {
    name = compName;
    edges = edges;
    target = "rs";
  };
in stdenv.mkDerivation (args // rec {
  inherit src mods osdeps;
  buildInputs = [purescript] ++ mods ++ osdeps;

  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];

  buildPhase = args.buildPhase or ''
    echo "*********************************************************************"
    echo "****** building ${type}: ${compName} "
    echo "*********************************************************************"
    ${
      if type == "pursagent" then ''
        ln -s ${unifiedSchema}/edge_capnp.rs edge_capnp.rs
        mkdir ./output
        SOURCES=("$src/src/**/*.purs")
        for pd in $mods; do
          for o in $pd/output/*; do
            rm -f ./output/$(basename $o)
            ln -s $o ./output/$(basename $o)
          done
          SOURCES+=("$pd/src/**/*.purs")
        done
        psc -o ./output "''${SOURCES[@]}"
      '' else ""}
  '';

  installPhase = ''
    mkdir -p $out
    cp -R --preserve=timestamps $src/src $out
    cp -R ./output $out
  '';
})
