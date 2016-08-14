{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , list_tuple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string list_tuple ];
  depsSha256 = "0mcyxrjl9lv6zcxlrr00w6dy99bpf96wdhskf2wrgw2skm7kcndl";

  meta = with stdenv.lib; {
    description = "Component: convert each JSON file into a vector of tuples";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/convert_json_vector;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
