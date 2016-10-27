{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ list_text ];
  depsSha256 = "0ka5sibfia5lcqqhqh84qwhdmwgxb476jps1vdn1vnas9kp384nl";

  meta = with stdenv.lib; {
    description = "Component: Print a list of texts to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/io/print/list/text;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
