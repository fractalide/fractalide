{ stdenv, buildFractalideSubnet, upkeepers, ...}:

buildFractalideSubnet rec {
  src = ./.;

  meta = with stdenv.lib; {
    description = "Subnet: OR logic gate";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/or;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
