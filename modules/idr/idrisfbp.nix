{ pkgs
, build-idris-package
, contrib
, prelude
, base
, idris
}:

let
  date = "2017-09-24";
in
build-idris-package {
  name = "idrisfbp-${date}";
  inherit pkgs;

  src = ./idrisfbp;

  propagatedBuildInputs = [ contrib base prelude ];

  meta = {
    description = "Flow-based programming libraries for idris.";
    homepage = https://github.com/fractalide/fractalide/modules/idr/idrisfbp;
    inherit (idris.meta) platforms;
  };
}
