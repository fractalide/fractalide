{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "net_ndn_interest" ];
  depsSha256 = "1q6manwllvp3xanwr1alf7yv886b7wmwfnj38sq1zyhmr3yahalw";
  meta = with stdenv.lib; {
    description = "Component: Prints NDN Interests";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/print/interest;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
