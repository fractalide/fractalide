
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, file_desc, list_command

, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [file_desc list_command];
  depsSha256 = "1iiq49yvnf8cpxvnxvvy4h3vy26xkzf5lc73p06xjw5d7282bwj0";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_generator_nix";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/flow;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
