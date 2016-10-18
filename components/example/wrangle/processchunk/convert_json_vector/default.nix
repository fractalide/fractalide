{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , list_tuple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string list_tuple ];
  depsSha256 = "1b87r6jbxfq12jv7fraiq02isc7zzk2s1z0hvfw5b3hwj4x58dd5";

  meta = with stdenv.lib; {
    description = "Component: convert each JSON file into a vector of tuples";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangle/convert_json_vector;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
