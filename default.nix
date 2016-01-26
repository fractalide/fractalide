{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, debug ? "--release"
, ...}:
let
support = import ./build-support {inherit pkgs debug contracts components;};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
doc = import ./doc {inherit pkgs;};
in
{
  inherit components contracts support doc;
  fvm = import ./fvm {inherit pkgs support components contracts;};
}

