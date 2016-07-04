{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["js_tag" "js_create" "generic_tuple_text" "generic_text"];
  depsSha256 = "0nxsyvy3pk5gxjsiig7vm28q2cjbr9a3gzxdybil6fkwcm7bv6qy";

  meta = with stdenv.lib; {
    description = "Component: draw a http tag";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
