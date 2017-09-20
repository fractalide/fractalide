{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.support // buffet );
# insert in alphabetical order in relevant section to reduce conflicts
in
# Schemas will undergo stability changes depending on any node (node-x) in any fractal becoming stable.
# It is the responsibility of that node-x's author to discuss with the author of the schema in question to stabilize the schema.
{
  # raw
  TestVect = callPackage ./test/vector {};
  # draft

  # stable

  # deprecated

  # legacy
}
