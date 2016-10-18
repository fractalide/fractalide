{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , net_ndn_data
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest net_ndn_data ];
  depsSha256 = "0jvd2zii7213wqm3q8y3fvn92cl677mjqz273ayx55il97bxg2lx";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Pending Interest Table";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/pit;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
