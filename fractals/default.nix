{ pkgs, support, contracts, components, ... }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support // contracts // components);
# insert in alphabetical order to reduce conflicts
self = rec {
  example_wrangle = callPackage ./example/wrangle {inherit pkgs support contracts components;};
  net_http = callPackage ./net/http {inherit pkgs support contracts components;};
  net_ndn = callPackage ./net/ndn {inherit pkgs support contracts components;};
  workbench = callPackage ./workbench {inherit pkgs support contracts components;};
};
in
self
