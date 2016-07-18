{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "protocol_domain_port" ];
  depsSha256 = "1sjvrlbry7p6gqazpijpdkjancyqakqmmykyjak67pqb6lm3jsbk";
  meta = with stdenv.lib; {
    description = "Component: Socket input";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/in;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
