{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text, list_command
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text list_command ];
  depsSha256 = "03idqayqb20aw5q24k8sy70mlgcs027agc1bim16j9hggw8l0v00";

  meta = with stdenv.lib; {
    description = "Component: shells_lain_parse: commands go in and flow script comes out.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/parse;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
