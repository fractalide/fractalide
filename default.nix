{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, debug ? "--release"
, ...}:
let
support = import ./build-support {inherit pkgs debug contracts components;};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
libfvm = import ./fvm/libfvm {inherit pkgs support components contracts;};
in
{
  inherit libfvm components contracts support;
  fvm = import ./fvm/fvm {inherit pkgs support libfvm;};
}
