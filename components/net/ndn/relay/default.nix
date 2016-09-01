{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn_relay_sort
  , net_ndn_relay_filter
  , ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
  // receiver receives packets coming from the ndn network
  // sender "sends" packets onto the ndn network
  'protocol_domain_port:(protocol="ws://",domain="127.0.0.1",port=8888)' -> start ws_client({net_websocket_client})
  'protocol_domain_port:(protocol="ws://",domain="127.0.0.1",port=8888)' -> option ws_client()

    // when an interest arrives your app needs to satisfy it if possible with data
    ws_client() output -> input sort(${net_ndn_relay_sort}) interest => interest

    // responding to the above interest
    data => input filter(${net_ndn_relay_filter}) output -> input ws_client()

    // when your app has an interest
    interest => input filter() output -> input ws_client()

    // the response to the interest your app just expressed
    ws_client() output -> input sort() data => data
  '';

  meta = with stdenv.lib; {
    description = "Subnet: net_ndn; Named Data Networking";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
