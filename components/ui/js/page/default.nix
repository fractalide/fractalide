{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , js_create
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text js_create ];
  depsSha256 = "1wf6a2ff7m45pv6dqc9qm30y8y58n7pk0740fmw5j837sphj85wh";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod button";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
