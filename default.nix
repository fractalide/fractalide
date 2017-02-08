{ node ? null
, local-rustfbp ? "false"
, debug ? "--release", test ? null, ...} @argsInput:
let
pkgs = import <nixpkgs> {};
lib = pkgs.lib;
nix-crates-index = pkgs.fetchFromGitHub {
  owner = "fractalide";
  repo = "nix-crates-index";
  rev = "e7f75876c0f3fc855c821d82bcb97ebae7d0e783";
  sha256 = "0s4zhzn45n6r2w7id1z55vqdgqj1jlcf6sxlk1z2wcbap8c01gvl";
};
callPackage = pkgs.lib.callPackageWith (pkgs);
origCrates = pkgs.recurseIntoAttrs (callPackage nix-crates-index { });
crates = if local-rustfbp == "true" then origCrates // { rustfbp = support.rustfbp;} else origCrates;
runThisNode = (builtins.head (lib.attrVals [node] nodes));
support = import ./support { inherit pkgs debug test nodes edges crates; };
fractals = import ./fractals { inherit buffet; };
imsg = callPackage ./support/imsg.nix {
  unifySchema = support.unifySchema ;
  capnpc-rust = support.capnpc-rust;
};
nodes = import ./nodes { inherit buffet; };
edges = import ./edges { inherit buffet; };
services = import ./services { inherit fractals; };
buffet = {
  support = support;
  edges = edges;
  imsg = imsg;
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
