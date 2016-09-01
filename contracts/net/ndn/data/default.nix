{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xb8fe0e9d444693c3;

  struct NetNdnData {
    name @0 :Text;
    metainfo @1 :Text;
    content @2 :Text;
    signature @3 :Text;
  }
  '';
  meta = with stdenv.lib; {
    description = "Contract: Describes a Named Data Network Interest";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/net/ndn/data;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
