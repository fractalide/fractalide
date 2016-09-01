{ stdenv, buildFractalideSubnet, upkeepers
  , net_ndn
  # contracts
  , net_ndn_interest
  , ...}:

buildFractalideSubnet rec {
  src = ./.;
  subnet = ''
  // receiver receives packets coming from the ndn network
  // sender "sends" packets onto the ndn network
  '${net_ndn_interest}:(name="interest",nonce=888)' -> interest ndn(${net_ndn})

  '';

  meta = with stdenv.lib; {
    description = "Subnet: net_ndn; Named Data Networking";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
