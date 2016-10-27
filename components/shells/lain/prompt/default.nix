
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text];
  depsSha256 = "02kxny0n1fwmyikjpvrnq3ixcab03zf9livib4wxv0k1wwilznhy";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh: a shell prompt.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shell/lain/pipe;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
