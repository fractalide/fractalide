{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text ];
  depsSha256 = "0xjwbdj2vgh67pr66wcy75mpjaj3wh6gsams1rm7k5b9c5kqdysh";

  meta = with stdenv.lib; {
    description = "Component: Clone the IPs coming in";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
