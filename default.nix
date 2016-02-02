{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, debug ? "--release"
, ...}:
let
support = import ./build-support {inherit pkgs debug contracts components;};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
fvm-android = import ./fvm/fvm-android {inherit pkgs support;};
in
{
  inherit components contracts support;
  fvm = import ./fvm/fvm {inherit pkgs support components contracts;};
}
