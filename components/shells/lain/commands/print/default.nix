{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text ];
  depsSha256 = "0s0fc01rasqlzmivh2b4r5y2rljknw9gx4bg2ddghmcicz5qkyxb";

  meta = with stdenv.lib; {
    description = "Component: Print to the terminal";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/shells/lain/commands/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
