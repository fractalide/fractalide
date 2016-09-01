{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0x9c951b3548fca4c2;

  struct FbpLexical {
    union {
      start @0 :Text;
      end @1 :Text;
      notFound @2 :Text;
      token :union {
        bind @3 :Void;
        external @4 :Void;
        comp :group {
          name @5 :Text;
          sort @6 :Text;
        }
        port :group {
          name @7 :Text;
          selection @8 :Text;
        }
        iip @9 :Text;
        break @10 :Void;
      }
    }
  }
  '';

  meta = with stdenv.lib; {
    description = "Contract: Describes the lexical structure of a Flow-based graph";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/fbp/lexical;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
