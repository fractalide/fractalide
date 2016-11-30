{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
    @0xbde554c96bf60f25;

    struct MathsNumber {
      number @0 :Int64;
    }
  '';
}
