{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text js_create ];
  depsSha256 = "0h987fj4f2zf89sxg6rxrgp2n0s0qh08p3q2n07gsswcy8l2bz39";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod button";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
