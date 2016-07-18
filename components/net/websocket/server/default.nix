{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "protocol_domain_port" ];
  depsSha256 = "0j6al3lvy3iz4dk50g452kh3dczj00h82z9lygabpqchy1yfffdv";

  meta = with stdenv.lib; {
    description = "Component: Socket output";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/out;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
