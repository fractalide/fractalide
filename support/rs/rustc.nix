{ lib
  , stdenv
  , git
  , rustNightly
  , genName
  , cratesSupport
  , unifySchema
}:

{ type ? ""}:

{ name ? null
  , src ? null
  , osdeps ? []
  , crates ? []
  , edges ? []
  , ... } @ args:

let
  compName = if name == null then genName src else name;
  unifiedSchema = unifySchema {
    name = compName;
    edges = edges;
    target = "rs";
  };
in stdenv.mkDerivation (args // rec {
  name = compName;
  buildInputs = osdeps;
  cratesDeps = cratesSupport.cratesDeps crates crates;
  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];
  buildPhase = args.buildPhase or ''
    echo "*********************************************************************"
    echo "****** building ${type}: ${compName} "
    echo "*********************************************************************"
    ${cratesSupport.symlinkCalc (cratesSupport.cratesDeps [] crates)}
    ${
      if type == "fvm" then ''
        ln -s ${unifiedSchema}/edge_capnp.rs edge_capnp.rs
        ${rustNightly}/bin/rustc main.rs \
        --crate-type bin \
        -O \
        --cap-lints "allow" -A dead_code -A unused_imports -A warnings \
        --emit=dep-info,link \
        --crate-name ${cratesSupport.normalizeName compName} \
        -L dependency=nixcrates ${cratesSupport.depsStringCalc crates} \
        -o fvm
      ''
      else if type == "executable" then ''
      ls -la
        ln -s ${unifiedSchema}/edge_capnp.rs src/edge_capnp.rs
        ${rustNightly}/bin/rustc src/main.rs \
        --crate-type bin \
        -O \
        --cap-lints "allow" -A dead_code -A unused_imports -A warnings \
        --emit=dep-info,link \
        --crate-name ${cratesSupport.normalizeName compName} \
        -L dependency=nixcrates ${cratesSupport.depsStringCalc crates} \
        -o ${compName}
      ''
      else if type == "agent" then ''
        ln -s ${unifiedSchema}/edge_capnp.rs edge_capnp.rs
        ${rustNightly}/bin/rustc lib.rs \
        --crate-type dylib \
        -O \
        --cap-lints "allow" -A dead_code -A unused_imports -A warnings \
        --emit=dep-info,link \
        --crate-name agent \
        -L dependency=nixcrates ${cratesSupport.depsStringCalc crates} \
        -o libagent.so
      ''
      else if type == "crate" then ''
        ln -s ${unifiedSchema}/edge_capnp.rs src/edge_capnp.rs
        ${rustNightly}/bin/rustc src/lib.rs \
        --crate-type lib \
        -O \
        --cap-lints "allow" -A dead_code -A unused_imports -A warnings \
        --emit=dep-info,link \
        --crate-name ${cratesSupport.normalizeName compName} \
        -L dependency=nixcrates ${cratesSupport.depsStringCalc crates} \
        -o lib${compName}.rlib
      ''
      else ""
    }
  '';

  installPhase = (args.installPhase or ''
    mkdir -p $out
    if [ ! -f ${unifiedSchema}/edge.capnp ]; then
      touch $out/edge.capnp
    else
      ln -s ${unifiedSchema}/edge.capnp $out/edge.capnp
    fi
    ${
      if type == "fvm" then ''
      mkdir -p $out/bin
      cp fvm $out/bin
      ''
      else if type == "executable" then ''
      mkdir -p $out/bin
      cp ${compName} $out/bin
      ''
      else if type == "agent" then ''
        mkdir -p $out/lib
        cp libagent.so $out/lib
      ''
      else if type == "crate" then ''
        mkdir -p $out
        cp lib${compName}.rlib $out/
      ''
      else ""
    }
  '' );
  })
