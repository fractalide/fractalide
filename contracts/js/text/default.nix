{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;

  meta = with stdenv.lib; {
    description = "Contract: Describes a text";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/ui/button;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
