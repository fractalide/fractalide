{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["key_value"];
  depsSha256 = "0xxc60hdwmvgdpag00zwk30l37wbvfkk74dy7k55x4k79v5ib43v";

  meta = with stdenv.lib; {
    description = "Component: accumulates a particulare key (determined by an IIP) and accumulates the values.";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/accumulate/keyValues;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
