{ buffet, genName }:
{ src, edges ? [], ... } @ args:

let
  stdenv = buffet.pkgs.stdenv;
  name = genName src;
in
  stdenv.mkDerivation (args // {
    name = name;
    src = src;
    installPhase = ''
      mkdir -p $out
      cp $src/edge.rs $out/edge.rs
    '';
  })
