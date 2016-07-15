{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [];
  depsSha256 = "0hj1s3a7nd05kk6z27jw2fgvi799g4m2dzsb31y54phssr0bb5ch";
  
  meta = with stdenv.lib; {
    description = "Component: Drop an Information Packet";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/drop/ip;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
