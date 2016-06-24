{lib, stdenv}:

stdenv.mkDerivation {
  name = "rustfbp";
  src = lib.cleanSource ../rustfbp;

  buildPhase = ''
  mkdir -p $out/src
  '';
  installPhase = ''
  cp -r src $out/src/
  cp Cargo.toml $out/src/Cargo.toml
  cp Cargo.lock $out/src/Cargo.lock
  '';
}
