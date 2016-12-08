{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
   @0xf6e41344bb789d96;

    struct Tuple {
      first @0 : Text;
      second @1 : Text;
    }
  '';
}
