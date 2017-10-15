{ backend ? "rs"
, node    ? null
, pkgs    ? import ./pkgs
, release ? true
, verbose ? false
}:
with pkgs.lib;
assert elem backend ["rs" "idr"];
let
  nodes    = import ./nodes    { inherit buffet; };
  edges    = import ./edges    { inherit buffet; };
  support  = import ./support  { inherit buffet; };
  fractals = import ./fractals { inherit buffet; };
  services = import ./services { inherit buffet; };
  mods     = import ./modules  { inherit buffet; };
  imsg     = support.imsg;
  buffet = {
    inherit support edges imsg nodes services fractals mods pkgs release verbose;
  };
  fvm = import (./nodes/fvm + "/${backend}") { inherit buffet; };
  bin = let
    targetNode = getAttrFromPath ["${backend}" "${node}"] nodes;
  in pkgs.writeTextFile {
    name = targetNode.name;
    text = ''
      #!${pkgs.stdenv.shell}
      ${fvm}/bin/fvm ${targetNode}
    '';
    executable = true;
  };
  pkg = if   node == null
        then fvm
        else bin;
in
{
  inherit buffet nodes edges support services pkg pkgs mods;
}
