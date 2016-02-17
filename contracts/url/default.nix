{stdenv, buildFractalideContract, ...}:

buildFractalideContract rec {
  src = ./.;

  meta = with stdenv.lib; {
    description = "Contract: url of type string";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/url;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
