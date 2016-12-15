{lib, stdenv, git, rustc
  , genName, crates-support
  , debug, test, local-rustfbp}:

{ name ? null
  , src ? null
  , osdeps ? []
  , crates ? []
  , edges ? []
  , binary ? "dylib"
  , ... } @ args:

let
  compName = if name == null then genName src else name;
in stdenv.mkCachedDerivation (args // rec {
  name = compName;
  buildInputs = crateDeps;
  crateDeps = crates-support.cratesDeps [] crates;
  #Don't forget to runHook, else the incremental builds wont work
  configurePhase = (args.configurePhase or "runHook preConfigure");
  buildPhase = args.buildPhase or ''
    echo "*********************************************************************"
    echo "****** building: ${compName} "
    echo "*********************************************************************"
    ${crates-support.symlinkCalc buildInputs}
    ${ if binary == "dylib" then ''
      propagated=""
      for i in $edges; do
        findInputs $i propagated propagated-build-inputs
      done
      propagated1=""
      for i in $propagated; do
        propagated1="$propagated1 $i/src/edge_capnp.rs"
      done
      touch src/edge_capnp.rs
      for i in $propagated1; do
        cat $i >> src/edge_capnp.rs
      done
      ${rustc}/bin/rustc src/lib.rs --crate-type ${binary} --emit=dep-info,link --crate-name agent -L dependency=mylibs ${crates-support.depsStringCalc crates} -o libagent.so
    ''
    else ''
      ${rustc}/bin/rustc src/main.rs --crate-type ${binary} --emit=dep-info,link --crate-name ${crates-support.normalizeName compName} -L dependency=mylibs ${crates-support.depsStringCalc crates} -o ${compName}
    ''}
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
    ${if binary == "dylib" then ''
    mkdir -p $out/lib
    cp libagent.so $out/lib
    ''
    else ''
    mkdir -p $out/bin
    cp ${compName} $out/bin
    ''}
  '' );
  })
