
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, file_desc, list_command

, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [file_desc list_command];
  depsSha256 = "0x1byxvv8q8g9v3rw24101kgz5yfs6lc8dk3j1wwflf5x6ibsd59";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_generator_nix";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/flow;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
