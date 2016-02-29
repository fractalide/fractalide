{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [];
  depsSha256 = "1kj8zgpjw3mwyx557iammq91hr4gyqyj1dyd7vwgybh7b2iaaddn";

  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Face";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/face;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
