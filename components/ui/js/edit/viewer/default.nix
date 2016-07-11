{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["generic_text" "generic_tuple_text"];
  depsSha256 = "17g2mjw2c7iwb5fdnh6382pjhxy02xnd4k7gnban1ac2c6j959mm";

  meta = with stdenv.lib; {
    description = "Component: split the fbp_graph in different ui_js components";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/app/editor/view;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
