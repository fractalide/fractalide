{ stdenv, buildFractalideComponent, genName, upkeepers
  , list_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ list_text ];
  depsSha256 = "0rzsjqxmzplwrbkhgf2m8m4myr0dqnaq3qrhsbassz50aadhbfy3";

  meta = with stdenv.lib; {
    description = "Component: Print a list of texts to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/io/print/list/text;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
