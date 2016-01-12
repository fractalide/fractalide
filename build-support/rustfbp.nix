{lib, stdenv, rustfbpPath}:

stdenv.mkDerivation {
  name = "rustfbp";
  src = lib.cleanSource rustfbpPath;

  buildPhase = ''
  mkdir -p $out/src
  '';
  installPhase = ''
  cp -r * $out/src
  rm -fr $out/src/target
  rm -fr $out/src/.git
  rm -fr $out/src/tests
  rm -fr $out/src/benches
  rm $out/src/default.nix
  '';
}

