{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, debug ? "--release"
, subnet ? ""
, local-rustfbp ? ""
, ...}:
let
exeSubnet = (builtins.head (lib.attrVals [subnet] components));
components = import ./components {inherit pkgs support;};
support = import ./build-support {inherit pkgs debug local-rustfbp contracts components;};
contracts = import ./contracts {inherit pkgs support;};
fvm-android = import ./fvm/fvm-android {inherit pkgs support;};
in
{
  inherit components support contracts;
  fvm = import ./fvm/fvm { inherit pkgs components contracts support exeSubnet;};
}
