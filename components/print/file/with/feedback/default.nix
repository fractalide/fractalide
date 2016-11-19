{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , list_triple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string list_triple];
  depsSha256 = "1sgm0bg7nbk422y7lh9hqzdnvfz2azjlh7vgq9bc265i4iwpi3ri";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
