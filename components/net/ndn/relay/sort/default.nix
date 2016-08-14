{ stdenv, buildFractalideComponent, genName, upkeepers
  , net_ndn_interest
  , net_ndn_data
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ net_ndn_interest net_ndn_data];
  depsSha256 = "0jpzxcjz7rgz8dkw83qsqh7dhp112qq94h4r3d4smnj8az698lws";
  meta = with stdenv.lib; {
    description = "Component: A Named Data Networking Forwarding Information Base";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/net/ndn/fib;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
