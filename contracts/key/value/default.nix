{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple key of type string and value of type Int 64";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/key/value;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
