{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["generic_text" "js_create"];
  depsSha256 = "1061hfkz5d3w0lfqqpwakyv4gj7mkr6ciz9s5psc2i42azgmzvrl";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod button";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
