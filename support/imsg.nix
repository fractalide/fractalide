{ lib, stdenv, writeTextFile, capnproto, capnpc-rust, unifySchema }:
{ class ? null, text ? "", option ? "" } @ args:
let
  unifiedSchema = unifySchema {
    name = class.name + "_transitives";
    edges = class;
    target = "capnp";
  };
  imsg-txt = writeTextFile {
    name = class.name + "_message";
    text = text;
    executable = false;
  };
  imsg = stdenv.mkDerivation {
    name = class.name + "_imsg";
    phases = [ "installPhase" ];
    installPhase = ''
    mkdir -p $out
    ${capnproto}/bin/capnp encode ${unifiedSchema}/edge.capnp ${class.name} < ${imsg-txt} > $out/imsg.bin
    '';
  };
in
  "${imsg}/imsg.bin${if option == "" then "" else "~${option}"}"
