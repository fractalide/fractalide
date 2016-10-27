
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, file_desc, list_command

, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [file_desc list_command];
  depsSha256 = "1cv8nd1056jnc4l43p3873zgq9l3vpd1kpnyj8xcjkij06xa7ya8";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_generator_nix";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/flow;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
