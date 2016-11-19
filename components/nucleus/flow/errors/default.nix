{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , fbp_semantic_error
  , file_error
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph fbp_semantic_error file_error ];
  depsSha256 = "1d4sk7g2s4gs1hgspndpgv727kkimjww6mc5z57awd4fj6xdix3x";

  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
