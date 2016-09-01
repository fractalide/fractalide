{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0x86b82a2fc79a7f6d;

  struct AppCounter {
    value @0 :Int64;
    delta @1 :Int64 = 1;
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes the Counter model";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/fbp/graph;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
