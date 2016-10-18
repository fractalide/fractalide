{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ list_text ];
  depsSha256 = "19b6icrxcx81qrmzq2xs7rjf0dnanz53ihnlpx3zxkka0p8d5jg3";

  meta = with stdenv.lib; {
    description = "Component: Print a list of texts to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/io/print/list/text;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
