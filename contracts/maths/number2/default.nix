{stdenv, pkgs, lib}:
let
contract = pkgs.writeTextFile {
  name = (baseNameOf ./.);
  text = builtins.readFile ./contract.capnp;
    executable = false;
};
in
pkgs.stdenv.mkDerivation rec {
  name = (baseNameOf ./.);
  unpackPhase = "true";
  installPhase = ''
  mkdir -p $out/src
  cp ${contract} $out/src/contract.capnp'';
}
