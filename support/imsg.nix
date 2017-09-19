{ buffet, lib, stdenv, writeTextFile, capnproto }:
{ class ? null, text ? "", option ? "" } @ args:
let
  unifyCapnpEdges = import ./edge/capnp/unifyCapnpEdges.nix { inherit buffet; };
  unifiedSchema = unifyCapnpEdges {
    name = class.name + "_trans";
    edges = class;
    target = "capnp";
  };
  imsg-txt = writeTextFile {
    name = class.name + "_text";
    text = text;
    executable = false;
  };
  imsg = stdenv.mkDerivation {
    name = class.name + "_schema";
    phases = [ "installPhase" ];
    installPhase = ''
    mkdir -p $out
    ${capnproto}/bin/capnp encode ${unifiedSchema}/edge.capnp ${class.name} < ${imsg-txt} > $out/imsg.bin
    '';
  };
in
  "${imsg}/imsg.bin${if option == "" then "" else "~${option}"}"
