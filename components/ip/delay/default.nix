{ stdenv, buildFractalideComponent, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [];
  depsSha256 = "05rhnrwkh3431fl6nkarhdqg1604s9zwa26yr2lh2rilvsm0d786";

  meta = with stdenv.lib; {
    description = "Component: Delay by 1 sec the IPs coming in";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
