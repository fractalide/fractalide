{lib, stdenv, git, rustNightly
  , genName, crates-support
  , unifySchema
  , debug, test}:

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
  cratesDeps = crates-support.cratesDeps crates crates;
  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];
  outputs = ["out" "schema" ];
  buildPhase = args.buildPhase or ''
    echo "*********************************************************************"
    echo "****** building: ${compName} "
    echo "*********************************************************************"
    ${crates-support.symlinkCalc (crates-support.cratesDeps [] crates)}
    ${
      if type == "executable" then ''
        ln -s ${unifiedSchema}/edge_capnp.rs src/edge_capnp.rs
        ${rustNightly}/bin/rustc src/main.rs \
        --crate-type bin \
        -O \
        --cap-lints "allow" -A dead_code -A unused_imports -A warnings \
        --emit=dep-info,link \
        --crate-name ${crates-support.normalizeName compName} \
        -L dependency=nixcrates ${crates-support.depsStringCalc crates} \
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
        -L dependency=nixcrates ${crates-support.depsStringCalc crates} \
        -o libagent.so
      ''
      else if type == "crate" then ''
        ln -s ${unifiedSchema}/edge_capnp.rs src/edge_capnp.rs
        ${rustNightly}/bin/rustc src/lib.rs \
        --crate-type lib \
        -O \
        --cap-lints "allow" -A dead_code -A unused_imports -A warnings \
        --emit=dep-info,link \
        --crate-name ${crates-support.normalizeName compName} \
        -L dependency=nixcrates ${crates-support.depsStringCalc crates} \
        -o lib${compName}.rlib
      ''
      else ""
    }
  '';

  installPhase = (args.installPhase or ''
    mkdir -p $schema
    if [ ! -f ${unifiedSchema}/edge.capnp ]; then
      touch $schema/edge.capnp
    else
      ln -s ${unifiedSchema}/edge.capnp $schema/edge.capnp
    fi
    ${
      if type == "executable" then ''
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
