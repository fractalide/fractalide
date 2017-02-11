{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    struct CoreActionSend {
           comp @0 :Text;
           port @1 :Text;
           selection @2 :Text;
    }
  '';
}
