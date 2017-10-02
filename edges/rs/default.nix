{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.support // buffet );
# insert in alphabetical order in relevant section to reduce conflicts
in
# Schemas will undergo stability changes depending on any node (node-x) in any fractal becoming stable.
# It is the responsibility of that node-x's author to discuss with the author of the schema in question to stabilize the schema.
{
  # raw
  CoreLexical = callPackage ./core/lexical {};
  CoreGraph = callPackage ./core/graph {};
  CoreSemanticError = callPackage ./core/semantic/error {};
  FsFileDesc = callPackage ./fs/file/desc {};
  TestConst = callPackage ./test/const {};
  TestEnum = callPackage ./test/enum {};
  TestNil = callPackage ./test/nil {};
  TestPair = callPackage ./test/pair {};
  TestPerson = callPackage ./test/person {};
  TestPoint = callPackage ./test/point {};
  TestRectangle = callPackage ./test/rectangle {};

  # draft

  # stable

  # deprecated

  # legacy
}
