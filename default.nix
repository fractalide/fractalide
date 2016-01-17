{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, buildType ? "--release"
, ...}:
let
support = import ./build-support {inherit pkgs buildType contracts;};
contracts = import ./contracts {inherit pkgs support;};
components = import ./components {inherit pkgs support;};
in
{
  inherit components contracts support;
  fractalide-toml = import ./mappings {inherit pkgs components contracts;};
}


