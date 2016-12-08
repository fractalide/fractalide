{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xd1376f2c4c24bf8b;

    struct GenericListText {
            listText @0 :List(Text);
    }
  '';
}
