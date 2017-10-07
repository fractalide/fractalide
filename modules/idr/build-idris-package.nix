{ pkgs, lib }: args:
let
  idris = import ./idris.nix { inherit pkgs; };
  mkDerivation = import ./build-idris-package-builder.nix args.pkgs idris;
  unifiedIdrisEdges = if (lib.attrByPath ["unifiedIdrisEdges"] [] args) == [] then {} else args.unifiedIdrisEdges;
  postPatch = if (lib.attrByPath ["postPatch"] [] args) == [] then "" else args.postPatch;
  unpackPhase = if (lib.attrByPath ["unpackPhase"] [] args) == [] then "" else args.unpackPhase;
  buildPhase = if (lib.attrByPath ["buildPhase"] [] args) == [] then "" else args.buildPhase;

in mkDerivation {
  name = args.name;
  src = args.src;
  propagatedBuildInputs = args.propagatedBuildInputs;
  inherit postPatch unpackPhase buildPhase;
} // unifiedIdrisEdges // args
