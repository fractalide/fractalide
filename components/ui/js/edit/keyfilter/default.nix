{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["generic_text" "generic_tuple_text"];
  depsSha256 = "01cxq5lr0klzf3fgywasr8hmrzyzshpzxhihi0ca5y8ip9vi9ady";

  meta = with stdenv.lib; {
    description = "Component: filter enter and escape keyup";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/app/editor/view;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
