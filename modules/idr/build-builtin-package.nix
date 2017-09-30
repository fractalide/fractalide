# Build one of the packages that come with idris
# name: The name of the package
# deps: The dependencies of the package
{ pkgs, idris, build-idris-package, lib }: name: deps:
let
  inherit (builtins.parseDrvName idris.name) version;
in
build-idris-package {
  name = "${name}-${version}";

  propagatedBuildInputs = deps;

  inherit (idris) src;
  inherit pkgs;

  postUnpack = ''
    ${name}
  '';

  postPatch = ''
    ${name}
  '';

  meta = idris.meta // {
    description = "${name} builtin Idris library";
  };
}
