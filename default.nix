{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, buildType ? "--release"
, rustfbpPath ? "false"
, ...}:
let
callPackage = lib.callPackageWith (pkgs // support // components // contracts);
support = import ./build-support {inherit pkgs buildType rustfbpPath contracts;};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
in
{
  inherit components contracts support;
  fractalide-toml = import ./mappings {inherit pkgs components contracts;};
}


