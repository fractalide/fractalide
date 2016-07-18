{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["generic_text"];
  depsSha256 = "0viy4mncd13a4m8p3pw0243dpwyk9fwvx74dqnar2gqv2y6gzykm";

  meta = with stdenv.lib; {
    description = "Component: Clone the IPs coming in";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
