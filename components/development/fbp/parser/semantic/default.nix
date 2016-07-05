{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["fbp_semantic_error" "fbp_graph" "fbp_lexical"];
  depsSha256 = "00i1qz2r37pvlfpkq1g21b38bdad0bd5li3d1y4p2qldvssvrrs5";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming semantics";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/semantic;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
