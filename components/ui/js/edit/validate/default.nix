{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text ];
  depsSha256 = "0p3jny79z8vz322qny86f31rbwmcxdfdlmzy8f75h8w8dvawkswp";

  meta = with stdenv.lib; {
    description = "Component: validate the input";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/app/editor/view;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
