{ buffet }:
buffet.support.node.idr.fvm {
  name = "fvm";
  src = ./.;
  mods = with buffet.mods.idr; [ contrib base prelude idrisfbp ];
  osdeps = with buffet.pkgs; [ gmp ];
  /*postPatch = with buffet.nodes; ''
    substituteInPlace FVM.idr --replace "fs_file_open.so" "-- ${idr.maths}/lib/libagent.so"
    substituteInPlace FVM.idr --replace "core_parser_lexical.so" "-- ${fvm_idr_scheduler}/lib/libagent.so"
  '';*/
}
