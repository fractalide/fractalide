{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xaf73df75f011fbb3;

  struct FileDesc {
      union {
        start @0 :Text;
        text @1 :Text;
        end @2 :Text;
      }
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes aspects of a file";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/file/desc;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
