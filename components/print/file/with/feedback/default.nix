{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , list_triple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string list_triple];
  depsSha256 = "0cx5nl04r03prj79q8hv4pg4ganmjy08rskqhgf4khdl5hr00psh";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
