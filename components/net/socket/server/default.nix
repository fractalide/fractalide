{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers
  , nanomsg
  ,...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [ "protocol_domain_port" ];
  buildInputs = [nanomsg];
  depsSha256 = "13165aqbv53dh2whlciy3i2dj7zjyx7gxz63d9yiw94xha7n2230";
  meta = with stdenv.lib; {
    description = "Component: Socket output";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/socket/out;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
