
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text];
  depsSha256 = "1vj7m8qqimipd3xah46szz4cphffc8axvapxbs4wgj6dfr504yzx";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh: a shell prompt.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shell/lain/pipe;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
