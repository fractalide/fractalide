{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.support // buffet );
# insert in alphabetical order in relevant section to reduce conflicts
in
{
  capnp = import ./capnp { inherit buffet; };
  idr = import ./idr { inherit buffet; };
  rs = import ./rs { inherit buffet; };
}
