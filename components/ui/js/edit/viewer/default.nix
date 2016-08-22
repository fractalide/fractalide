{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , generic_tuple_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text generic_tuple_text ];
  depsSha256 = "07wyl35nnbgjrrfr199znqakksc8xxp2i8gvq1ksp4ak7p227y0n";

  meta = with stdenv.lib; {
    description = "Component: split the fbp_graph in different ui_js components";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/app/editor/view;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
