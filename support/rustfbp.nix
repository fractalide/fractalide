{lib, stdenv}:

stdenv.mkCachedDerivation {
  name = "rustfbp";
  src = lib.cleanSource ./rustfbp;

  buildPhase = ''
  mkdir -p $out/src
  '';
  installPhase = ''
  runHook preInstall
  cp -r src $out/src/
  cp Cargo.toml $out/src/Cargo.toml
  cp Cargo.lock $out/src/Cargo.lock
  '';
}
