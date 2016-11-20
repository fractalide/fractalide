{ stdenv, buildFractalideComponent, genName, upkeepers
  , maths_number
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ maths_number ];
  depsSha256 = "028xyjzfbiz7mxhdmwb55dg5npr1flwhbjkzsrlj4f92cq8n7vr7";

  meta = with stdenv.lib; {
    description = "Component: Adds all inputs together";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/add;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
