{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, fetchgit ? pkgs.fetchgit
}:

let strs = {
  rustfbp = "../rustfbp";
  generate_msg = "../generate-msg";
  cardano = builtins.readFile ./cardano/cardano.nix;
};
in

{
  inherit strs;
  vals = {
    rustfbp = ../rustfbp;
    generate_msg = ../generate-msg;
    cardano = import ./cardano {};
  };
}
