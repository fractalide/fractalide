{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.support // buffet );
# insert in alphabetical order in relevant section to reduce conflicts
in
# Schemas will undergo stability changes depending on any node (node-x) in any fractal becoming stable.
# It is the responsibility of that node-x's author to discuss with the author of the schema in question to stabilize the schema.
{
  # raw
  test_const = callPackage ./test/const {};
  test_enum = callPackage ./test/enum {};
  test_linked_list = callPackage ./test/linked_list {};
  test_nil = callPackage ./test/nil {};
  test_pair = callPackage ./test/pair {};
  test_person = callPackage ./test/person {};
  test_point = callPackage ./test/point {};
  test_rectangle = callPackage ./test/rectangle {};

  # draft

  # stable

  # deprecated

  # legacy
}
