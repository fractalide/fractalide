{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0xda3ac78deff8e9e9;

  struct NetNdnInterest {
    name @0 :Text;
    nonce @1 :Int32;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes a Named Data Network Interest";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/net/ndn/interest;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
