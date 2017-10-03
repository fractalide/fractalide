{ lib }: args:
let
  mkDerivation = import ./build-idris-package-builder.nix args.pkgs;
  unifiedIdrisEdges = if (lib.attrByPath ["unifiedIdrisEdges"] [] args) == [] then {} else args.unifiedIdrisEdges;
  postUnpack = if (lib.attrByPath ["postUnpack"] [] args) == [] then "" else args.postUnpack;
  postPatch = if (lib.attrByPath ["postPatch"] [] args) == [] then "" else args.postPatch;

in mkDerivation {
  name = args.name;
  src = args.src;
  propagatedBuildInputs = args.propagatedBuildInputs;
  inherit postUnpack postPatch;
} // unifiedIdrisEdges // args
