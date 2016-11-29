{ contract, contracts }:

contract {
  src = ./.;
  importedContracts = with contracts; [];
  schema = with contracts; ''
    @0xb547a1eef762172e;

    struct OptionPath {
        union {
            path @0 :Text;
            none @1 :Void;
        }
    }
  '';
}
