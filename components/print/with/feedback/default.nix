{ stdenv, buildFractalideComponent, genName, upkeepers
  , path
  , value_string
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ path value_string ];
  depsSha256 = "0y72l462xpc6d4569245xadh4sdrfj01nclaqs57hhzcz40br7cm";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
