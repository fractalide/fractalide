
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text, list_text

, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text list_text];
  depsSha256 = "0mdlfbcndlry6sg3j8c01kjpcijlljbiy1179499bkq2xbv4pgbx";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_generator_nix";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/maths/boolean/nand;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
