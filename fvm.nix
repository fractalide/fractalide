{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, debug ? "--release"
, fbp ? ""
, ...}:
let
name = "subnet";
subnet-txt = pkgs.writeTextFile {
  name = name;
  text = builtins.readFile fbp;
  executable = false;
};
support = import ./build-support {inherit pkgs debug contracts components;};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
fvm-android = import ./fvm/fvm-android {inherit pkgs support;};
fvm = import ./fvm/fvm { inherit pkgs components contracts support fbp;};
in
fvm

