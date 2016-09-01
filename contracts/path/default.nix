{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xad6ca52dabb3c4fd;

  struct Path {
          path @0 :Text;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple path of type string";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/path;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
