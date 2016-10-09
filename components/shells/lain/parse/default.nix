{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text, list_command
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text list_command ];
  depsSha256 = "1s8nia8mxwc6lsr6hqdjklrh5nhffwcv1dyb4jpnwflim7drh0v3";

  meta = with stdenv.lib; {
    description = "Component: shells_lain_parse: commands go in and flow script comes out.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/parse;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
