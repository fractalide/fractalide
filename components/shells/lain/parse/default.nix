{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, list_text, shell_commands
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [list_text shell_commands];
  depsSha256 = "1a5f8bygx4iz0dxclw25chjfvamfyw74hx4fw16n9g4r63gy96lf";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_build_names: commands go in and flow script comes out.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/maths/boolean/nand;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
