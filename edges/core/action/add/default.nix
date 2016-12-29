{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    @0xb15de9c2c13e4bb2;

    struct CoreActionAdd {
           name @0 :Text;
           comp @1 :Text;
    }
  '';
}
