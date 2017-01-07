{lib, stdenv, git, rustNightly
  , genName, crates-support
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
in stdenv.mkDerivation (args // rec {
  name = compName;
  buildInputs = osdeps;
  cratesDeps = crates-support.cratesDeps crates crates;
  #Don't forget to runHook, else the incremental builds wont work
  configurePhase = (args.configurePhase or "runHook preConfigure");
  buildPhase = args.buildPhase or ''
    echo "*********************************************************************"
    echo "****** building: ${compName} "
    echo "*********************************************************************"
    ${crates-support.symlinkCalc (crates-support.cratesDeps [] crates)}
    propagated=""
    for i in $edges; do
      findInputs $i propagated propagated-build-inputs
    done
    propagated1=""
    for i in $propagated; do
      propagated1="$propagated1 $i/src/edge_capnp.rs"
    done
    ${ if type == "agent" then ''
      touch edge_capnp.rs
      for i in $propagated1; do
        cat $i >> edge_capnp.rs
      done
      ${rustNightly}/bin/rustc lib.rs \
      --crate-type dylib \
      -O \
      --cap-lints "allow" -A dead_code -A unused_imports -A warnings \
      --emit=dep-info,link \
      --crate-name agent \
      -L dependency=nixcrates ${crates-support.depsStringCalc crates} \
      -o libagent.so
    ''
    else if type == "executable" then ''
      touch src/edge_capnp.rs
      for i in $propagated1; do
        cat $i >> src/edge_capnp.rs
      done
      ${rustNightly}/bin/rustc src/main.rs \
      --crate-type bin \
      -O \
      --cap-lints "allow" -A dead_code -A unused_imports -A warnings \
      --emit=dep-info,link \
      --crate-name ${crates-support.normalizeName compName} \
      -L dependency=nixcrates ${crates-support.depsStringCalc crates} \
      -o ${compName}
    ''
    else if type == "crate" then ''
      ${rustNightly}/bin/rustc src/lib.rs \
      --crate-type lib \
      -O \
      --cap-lints "allow" -A dead_code -A unused_imports -A warnings \
      --emit=dep-info,link \
      --crate-name ${crates-support.normalizeName compName} \
      -L dependency=nixcrates ${crates-support.depsStringCalc crates} \
      -o lib${compName}.rlib
    '' else ""
  }
  '';

  checkPhase = if test == null then "echo skipping tests in debug mode"
  else args.checkPhase or ''
  echo "Running cargo test"
  cargo test
  '';

  doCheck = args.doCheck or true;

  #Don't forget to runHook, else the incremental builds wont work
  installPhase = (args.installPhase or ''
    runHook preInstall
    ${
      if type == "agent" then ''
        mkdir -p $out/lib
        cp libagent.so $out/lib
      ''
      else if type == "executable" then ''
        mkdir -p $out/bin
        cp ${compName} $out/bin
      ''
      else if type == "crate" then ''
        mkdir -p $out
        cp lib${compName}.rlib $out/
      ''
      else ""
    }
  '' );
  })
