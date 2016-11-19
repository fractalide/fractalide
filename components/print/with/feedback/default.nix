{ stdenv, buildFractalideComponent, genName, upkeepers
  , path
  , value_string
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ path value_string ];
  depsSha256 = "1cn4ffnf5l3gn8a9aipmim8ih5fy3p7bvkr6ma8r1318pjkkqpvz";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
