{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["app_counter"];
  depsSha256 = "12xq209lh0dy90b8xig0ha3p56vd9l593j406hs4lmn3r2ddmz8i";

  meta = with stdenv.lib; {
    description = "Component: decrease by one the number";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
