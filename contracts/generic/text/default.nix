{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
    @0xb1fc090ed4d12aee;

    struct GenericText {
            text @0 :Text;
    }
  '';
}
