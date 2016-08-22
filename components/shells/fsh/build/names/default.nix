
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text

, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text];
  depsSha256 = "0gqh8bgzyq5ymmnslbpgyjic3iws6v9wmjsk3k84l6hgvda0x7q0";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_build_names: commands go in and flow script comes out.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/maths/boolean/nand;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
