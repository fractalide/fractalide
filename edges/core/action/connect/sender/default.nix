{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    struct CoreActionConnectSender {
           name @0 :Text;
           port @1 :Text;
           selection @2 :Text;
           output @3 :Text;
    }

  '';
}
