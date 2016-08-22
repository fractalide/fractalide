
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text];
  depsSha256 = "0wv25hibldyx9l5krjx8cicgvhixw28sn0mr0n0n13lz8psv4x3y";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_parse_pipe: create fipes.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/fsh/parse/pipe;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
