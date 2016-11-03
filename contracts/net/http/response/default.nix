{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xb10b096b4e676688;

  struct NetHttpResponse {
    id @0 :UInt64;
    response @1 :Text;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes an http response";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/maths/boolean;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
