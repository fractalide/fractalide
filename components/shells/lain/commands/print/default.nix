{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text ];
  depsSha256 = "0nh85zb5336s8h1b9pljqacd3n9wrqnnkzflqp8kjrgc5rsgq3rd";

  meta = with stdenv.lib; {
    description = "Component: Print to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/shells/lain/commands/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
