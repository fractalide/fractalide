{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["js_create" "generic_tuple_text" "generic_text" "generic_bool"];
  depsSha256 = "01yp5rbzprk4676mgw1yi0bq7pgb63bv00q045bdsx0j9zxnmb61";

  meta = with stdenv.lib; {
    description = "Component: draw a http tag";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
