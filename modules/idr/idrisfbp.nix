{ pkgs
, build-idris-package
, contrib
, idris
}:

let
  date = "2017-09-24";
in
build-idris-package {
  name = "idrisfbp-${date}";

  src = ./idrisfbp;

  propagatedBuildInputs = [ contrib ];

  meta = {
    description = "Flow-based programming libraries for idris.";
    homepage = https://github.com/fractalide/fractalide/modules/idr/idrisfbp;
    inherit (idris.meta) platforms;
  };
}
