{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
    @0xa3cd85e8335a7357;

    struct ListText {
            texts @0 :List(Text);
    }
  '';
}
