{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ list_text ];
  depsSha256 = "1nsmmp5lgw43jbgrg3vcxzckr382s94alh4lpxr1pp3p21mxavka";

  meta = with stdenv.lib; {
    description = "Component: Print a list of texts to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/io/print/list/text;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
