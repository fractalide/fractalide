{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text, list_command
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text list_command ];
  depsSha256 = "1nlh9a4lvq1qvnb8fvagvp3amasahyf4ns687z1aca3kgd50nhdr";

  meta = with stdenv.lib; {
    description = "Component: shells_lain_parse: commands go in and flow script comes out.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/parse;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
