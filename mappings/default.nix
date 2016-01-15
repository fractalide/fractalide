{ pkgs, components, contracts }:
let
callPackage = pkgs.lib.callPackageWith (pkgs);
rust-component-lookup = callPackage ./rust-component-lookup.nix { inherit components; };
rust-contract-lookup = callPackage ./rust-contract-lookup.nix { inherit contracts; };
fractalide-toml-txt = pkgs.writeTextFile {
  name = "fractalide.toml";
  text =
  ''
  [mappings]
  rust-component-lookup = ${rust-component-lookup}/lib/librust_component_lookup.so
  rust-contract-lookup = ${rust-contract-lookup}/lib/librust_contract_lookup.so
  '';
};
in
pkgs.stdenv.mkDerivation rec {
  name = "fractalide-toml";
  unpackPhase = "true";
  installPhase = ''
  mkdir -p $out/conf
  cp -r  ${fractalide-toml-txt} $out/conf/fractalide.toml
  '';
  shellHook = ''
  export FRACTALIDE_TOML=${fractalide-toml-txt}
  '';
}
