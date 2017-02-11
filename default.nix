{ rs ? null }:
let
  pkgs = import <nixpkgs> {};
  target = { name = "rs"; nodes = nodes.rs; node = rs;};
  targetNode = (builtins.head (pkgs.lib.attrVals [target.node] target.nodes));
  nodes = import ./nodes { inherit buffet; };
  edges = import ./edges { inherit buffet; };
  support = import ./support { inherit buffet; };
  fractals = import ./fractals { inherit buffet; };
  services = import ./services { inherit buffet; };
  mods = import ./modules { inherit buffet; };
  imsg = support.imsg;
  buffet = {
    support = support;
    edges = edges;
    imsg = imsg;
    nodes = nodes;
    services = services;
    fractals = fractals;
    mods = mods;
    pkgs = pkgs;
  };
  fvm = import (./nodes/fvm + "/${target.name}") { inherit buffet; };
in
{
  inherit buffet nodes edges support services;
  result = if target.node == null
  then fvm
  else pkgs.writeTextFile {
    name = targetNode.name;
    text = "${fvm}/bin/fvm ${targetNode}";
    executable = true;};
}
