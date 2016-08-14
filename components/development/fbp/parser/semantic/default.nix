{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_semantic_error
  , fbp_graph
  , fbp_lexical
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_semantic_error fbp_graph fbp_lexical ];
  depsSha256 = "0wvkgvm400fgvr5s3fjkm4x1z6fna6mz1iydpd2x77glc4p71ipa";

  meta = with stdenv.lib; {
    description = "Component: Flow-based programming semantics";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/parser/fbp/semantic;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
