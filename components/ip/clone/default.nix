{ stdenv, buildFractalideComponent, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [];
  depsSha256 = "0xjwbdj2vgh67pr66wcy75mpjaj3wh6gsams1rm7k5b9c5kqdysh";

  meta = with stdenv.lib; {
    description = "Component: Clone the IPs coming in";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
