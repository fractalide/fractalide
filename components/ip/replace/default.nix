{ stdenv, buildFractalideComponent, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [];
  depsSha256 = "1079909flkk0r4i2xmipism7j7n9zl9jl6wrbxzg1qcc86dn87yr";

  meta = with stdenv.lib; {
    description = "Component: Dispatch the IPs coming in";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
