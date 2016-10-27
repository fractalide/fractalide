{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text ];
  depsSha256 = "0hfqnnqhrm20lvs2wxfsbsh9xjsv3wva9ypkn2dw5gdbkn2nmqah";

  meta = with stdenv.lib; {
    description = "Component: Print to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/shells/lain/commands/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
