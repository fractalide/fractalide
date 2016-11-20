
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text];
  depsSha256 = "19mfdmb0myajyryghhck7pqi5z6ri1yndl8kwwdx9w3wa3y142zv";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh: a shell prompt.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shell/lain/pipe;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
