{ debug ? "--release"
, node ? null
, local-rustfbp ? "false"
, cache ? null
, test ? null
, ...} @argsInput:
let
#get the old pkgs if given from an parameter, else import it
pkgs = import <nixpkgs> {};
lib = pkgs.lib;
nix-crates-index = pkgs.fetchFromGitHub {
  owner = "fractalide";
  repo = "nix-crates-index";
  rev = "3e3833886aeeb4c1e67a42f812519a053156513f";
  sha256 = "0xq970m1lwl7drsx8f5dq55kgfds35ms2k4imadcyqi858bnwjw2";
};
origCrates = pkgs.recurseIntoAttrs (pkgs.callPackage nix-crates-index { });
crates = if local-rustfbp == "true" then origCrates // { rustfbp = support.rustfbp;} else origCrates;
runThisNode = (builtins.head (lib.attrVals [node] nodes));
support = import ./support { inherit pkgs debug test nodes edges crates; };
fractals = import ./fractals { inherit buffet; };
nodes = import ./nodes { inherit buffet; };
edges = import ./edges { inherit buffet; };
services = import ./services { inherit fractals; };
buffet = {
  support = support;
  edges = edges;
  nodes = nodes;
  services = services;
  fractals = fractals;
  crates = crates;
  pkgs = pkgs;
};
fvm = import ./support/fvm { inherit buffet; };
in
{
  inherit buffet nodes edges support services;
  result = if node == null
  then fvm
  else pkgs.writeTextFile {
    name = runThisNode.name;
    text = "${fvm}/bin/fvm ${runThisNode}";
    executable = true;};
}
