{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xa3cd85e8335a7357;

    struct ListText {
            texts @0 :List(Text);
    }
  '';
}
