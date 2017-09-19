{ buffet, genName }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.pkgs );
in
{
  capnp = callPackage ./capnp { inherit genName; };
  rs = callPackage ./rs { inherit genName; };
}
