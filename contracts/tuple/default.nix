{ contract, contracts }:

contract {
  src = ./.;
  contracts =  with contracts; [];
  schema = with contracts; ''
   @0xf6e41344bb789d96;

    struct Tuple {
      first @0 : Text;
      second @1 : Text;
    }
  '';
}
