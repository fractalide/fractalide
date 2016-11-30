{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
    @0xd1376f2c4c24bf8b;

    struct GenericListText {
            listText @0 :List(Text);
    }
  '';
}
