{ stdenv, buildFractalideSubnet, upkeepers
  # contracts
  , protocol_domain_port
  , ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
  // receiver receives packets coming from the ndn network
  // sender "sends" packets onto the ndn network
  '${protocol_domain_port}:(protocol="ws://",domain="127.0.0.1",port=8888)' -> start relay({net_websocket_server})
  '${protocol_domain_port}:(protocol="ws://",domain="127.0.0.1",port=8888)' -> option relay()

    // when an interest arrives your app needs to satisfy it if possible with data
    relay() interest => interest

    // responding to the above interest
    data => data relay()

    // when your app has an interest
    interest => interest relay()

    // the response to the interest your app just expressed
    relay() data => data
  '';

  meta = with stdenv.lib; {
    description = "Subnet: net_ndn; Named Data Networking";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/router;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
