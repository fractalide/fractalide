{ stdenv, buildFractalideSubnet, upkeepers, ...}:

buildFractalideSubnet rec {
  src = ./.;

  meta = with stdenv.lib; {
    description = "Subnet: Not logic gate";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/not;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
