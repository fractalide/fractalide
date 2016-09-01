{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xb547a1eef762172e;

  struct OptionPath {
      union {
          path @0 :Text;
          none @1 :Void;
      }
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a simple path of type string";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/path;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
