{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["fbp_semantic_error" "fbp_graph" "fbp_lexical"];
  depsSha256 = "1mzk49cw0ygamm0s1003zsxxpqj93i3x7yyjyxysngcxn39h4ly9";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming semantics";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/semantic;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
