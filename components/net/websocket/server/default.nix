{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , nanomsg
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "protocol_domain_port" ];
  buildInputs = [nanomsg];
  depsSha256 = "06mjncygiph2hj6h048jngz398w4ff7cswl8afvi0mpacw5fbgxh";
  meta = with stdenv.lib; {
    description = "Component: Socket output";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/out;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
