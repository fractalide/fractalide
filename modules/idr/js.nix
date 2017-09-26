{ pkgs
, build-idris-package
, fetchFromGitHub
, lightyear
, contrib
, prelude
, base
, pruviloj
, effects
, lib
, idris
}:

let
  date = "2017-09-22";
in
build-idris-package {
  name = "idrisjs-${date}";

  src = fetchFromGitHub {
    owner = "rbarreiro";
    repo = "idrisjs";
    rev = "f681214f7ffeacad9587d5304be719f99b84cf1a";
    sha256 = "0r7m6gfg6pzy660184pk6bm4c2dy6pwrmb1lvfrc9z9r1pkygxc9";
  };

  propagatedBuildInputs = [ prelude base contrib lightyear effects pruviloj ];

  meta = {
    description = "Js libraries for idris.";
    homepage = https://github.com/rbarreiro/idrisjs;
    inherit (idris.meta) platforms;
  };
}
