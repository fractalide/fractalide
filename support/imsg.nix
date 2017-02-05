{ lib, stdenv, capnproto, capnpc-rust, unifySchema }:
{ edges ? [] } @ args:
let
  unifiedSchema = unifySchema {
    name = "composed-schema";
    edges = edges;
    target = "capnp";
  };
  unifiedImsgs = stdenv.mkDerivation (args // rec {
    name = "composed-imsgs";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      ln -s ${unifiedSchema}/edge.capnp $out/edge.capnp
    '';
  });
in
  "${unifiedImsgs}"
