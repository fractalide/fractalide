{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "value_string" "list_triple"];
  depsSha256 = "0kk62dgi7bys53grhsj67n59hacjg5nbdi2vy489np2gls7b1a32";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
