{ lib
  , stdenv
  , idris
  , gmp
  , gcc
  , build-idris-package
  , genName
}:

{ fractalType ? ""}:

{ name ? null
  , src ? null
  , mods ? []
  , edges ? []
  , ipkg ? ""
  , ...
} @ args:

let
  compName = if name == null then genName src else name;
in build-idris-package (args // rec {
  name = compName;
  inherit src;
  prePatch = ''
    if [ -e agent.ipkg ]; then
      substituteInPlace agent.ipkg --replace nix_replace_me ${compName}
    fi
  '';
  propagatedBuildInputs = mods;
})
