{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, list_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [list_text];
  depsSha256 = "01smm8zf225j2sg4l0fd07s6nv5pjs08vxf0q2qdk171spnd00bp";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_parse_verify";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/maths/boolean/nand;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
