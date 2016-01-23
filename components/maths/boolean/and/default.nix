{ stdenv, buildFractalideSubnet, filterDeps, upkeepers, ...}:

buildFractalideSubnet rec {
  src = ./.;

  meta = with stdenv.lib; {
    description = "Subnet: AND logic gate";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/and;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
