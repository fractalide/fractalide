
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text];
  depsSha256 = "1zqapn7fanj8n8wcwal829ymjwlbbza8j4z57kc176zrfbsc06i4";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh: a shell prompt.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shell/lain/pipe;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
