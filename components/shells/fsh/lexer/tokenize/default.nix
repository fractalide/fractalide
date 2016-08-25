{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, list_text, shell_commands
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [list_text shell_commands];
  depsSha256 = "1zk12l8rxwsm3ivsjxh9s6x7nb4rl70b6k0pxz3z8ldyasbn4ji1";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_build_names: commands go in and flow script comes out.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/maths/boolean/nand;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
