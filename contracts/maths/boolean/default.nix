{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
    @0xbde554c96bf60f36;

    struct MathsBoolean {
      boolean @0 :Bool;
    }
  '';
}
