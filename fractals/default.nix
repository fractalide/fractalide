{ pkgs, support, contracts, components, ... }:
let
callPackage = pkgs.lib.callPackageWith (pkgs // support // contracts // components);
# insert in alphabetical order to reduce conflicts
self = rec { 
  net_http = callPackage ./net/http {inherit pkgs support contracts components;};
};
in
self
