{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn_relay
  , ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
    // when an interest arrives your app needs to satisfy it if possible with data
    relay(${net_ndn_relay}) interest => interest

    // responding to the above interest
    data => data relay()

    // when your app has an interest
    interest => interest relay()

    // the response to the interest your app just expressed
    relay() data => data
  '';

  meta = with stdenv.lib; {
    description = "Subnet: net_ndn; Named Data Networking";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
