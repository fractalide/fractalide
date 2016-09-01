{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text js_create ];
  depsSha256 = "1j3ghhs5bbvpg3gqjvzmx4wm4rm59nppbvbqm97nv2xxmfqyxjzj";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod button";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
