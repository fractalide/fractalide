{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , list_triple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string list_triple];
  depsSha256 = "1gvhas7mffkn14g0p7hvcf3gxvc2wkh40z08x55a1piaq6jfbmcd";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
