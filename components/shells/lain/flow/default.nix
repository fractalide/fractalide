
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, file_desc, list_command

, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [file_desc list_command];
  depsSha256 = "0rm9yca3h76bi29xhjrx5m5ppyc5qhl9r64106hmr37mpdiz3cnj";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_generator_nix";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/flow;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
