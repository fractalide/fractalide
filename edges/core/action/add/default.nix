{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    struct CoreActionAdd {
           name @0 :Text;
           comp @1 :Text;
    }
  '';
}
