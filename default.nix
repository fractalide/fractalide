{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, buildType ? "--release"
, ...}:
let
support = import ./build-support {inherit pkgs buildType contracts;};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
mappings = import ./mappings {inherit pkgs components contracts;};
in
{
  inherit components contracts support;
  fvm = import ./fvm {inherit pkgs support mappings components contracts;};
}


