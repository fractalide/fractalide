{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["js_create" "js_placeholder"];
  depsSha256 = "0bhc7hg1q6h5hqzv80p36jm0zhmcpk8qq28pb3yr1ilpx7x4qn2z";
  meta = with stdenv.lib; {
    description = "Component: draw a place holder";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
