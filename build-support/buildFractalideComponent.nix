{lib, stdenv, cacert, git, rustc, cargo
  , capnproto, capnpc-rust, rustRegistry
  , debug, local-rustfbp}:

{ name, depsSha256
  , src ? null
  , srcs ? null
  , sourceRoot ? null
  , buildInputs ? []
  , filteredContracts ? []
  , cargoUpdateHook ? ""
  , ... } @ args:

  let
  rustfbp = import ./rustfbp.nix {inherit lib stdenv;};

  fetchDeps = import ./fetchcargo.nix {
    inherit stdenv cacert git cargo rustc rustRegistry;
  };

  cargoDeps = fetchDeps {
    inherit name src srcs sourceRoot cargoUpdateHook;
    sha256 = depsSha256;
  };

  type = if debug == "true" then "" else "--release";
  directory = if debug == "true" then "debug" else "release";

  in stdenv.mkCachedDerivation (args // {
    inherit cargoDeps rustRegistry capnproto capnpc-rust;

    patchRegistryDeps = ./patch-registry-deps;
    buildInputs = [ git cargo rustc ] ++ buildInputs;
    #Don't forget to runHook, else the incremental builds wont work
    configurePhase = (args.configurePhase or "runHook preConfigure");
    postUnpack = ''
    echo "Using cargo deps from $cargoDeps"

    cp -r "$cargoDeps" deps
    chmod +w deps -R

    # It's OK to use /dev/null as the URL because by the time we do this, cargo
    # won't attempt to update the registry anymore, so the URL is more or less
    # irrelevant

    cat <<EOF > deps/config
    [registry]
    index = "file:///dev/null"
    EOF

    export CARGO_HOME="$(realpath deps)"

    # Let's find out which $indexHash cargo uses for file:///dev/null
    (cd $sourceRoot && cargo fetch &>/dev/null) || true
    cd deps
    indexHash="$(basename $(echo registry/index/*))" #*/

    echo "Using indexHash '$indexHash'"

    rm -rf -- "registry/cache/$indexHash" \
    "registry/index/$indexHash"

    mv registry/cache/HASH "registry/cache/$indexHash"

    echo "Using rust registry from $rustRegistry"
    ln -s "$rustRegistry" "registry/index/$indexHash"

    # Retrieved the Cargo.lock file which we saved during the fetch
    cd ..
    mv deps/Cargo.lock $sourceRoot/
    (
      cd $sourceRoot
      cargo fetch
      cargo clean
      ) '' + (args.postUnpack or "");

prePatch = ''
# Patch registry dependencies, using the scripts in $patchRegistryDeps
(
  set -euo pipefail
  cd ../deps/registry/src/*

  for script in $patchRegistryDeps/*; do
  # Run in a subshell so that directory changes and shell options don't
  # affect any following commands

  ( . $script)
  done
  )
'' + (args.prePatch or "");

buildPhase = args.buildPhase or ''
sed -i "s/name = .*/name = \"component\"/g" Cargo.toml
${if local-rustfbp == "true" then
"sed -i 's@rustfbp .*@rustfbp = { path = \"${rustfbp + /src}\" }@g' Cargo.toml"
else ""}
${stdenv.lib.concatMapStringsSep "\n"
(contract:
  "cp ${contract.outPath}/src/contract_capnp.rs ./${contract.name}.rs;")
(stdenv.lib.flatten filteredContracts)}
echo "*********************************************************************"
echo "****** building: ${name} "
echo "*********************************************************************"
echo "Running cargo build ${type}"
cargo build ${type}
'';

checkPhase = if debug == "true" then "echo skipping tests in debug mode"
else args.checkPhase or ''
echo "Running cargo test"
cargo test
'';

doCheck = args.doCheck or true;

#Don't forget to runHook, else the incremental builds wont work
installPhase = (args.installPhase or ''
runHook preInstall
mkdir -p $out/lib
for f in $(find target/${directory} -maxdepth 1 -type f); do
cp $f $out/lib
done;
'' );
})
