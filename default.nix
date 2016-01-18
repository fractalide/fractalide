{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, buildType ? "--release"
, ...}:
let
support = import ./build-support {inherit pkgs buildType contracts components;};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
in
{
  inherit components contracts support;
  fvm = import ./fvm {inherit pkgs support components contracts;};
}


