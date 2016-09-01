{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text js_create ];
  depsSha256 = "00dnpk3ickx0njnr2n51vv46jj0hrs2svy15gy48rczcgz1lm3fh";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod text";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
