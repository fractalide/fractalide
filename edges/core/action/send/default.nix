{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    @0xeaa980bee40312b8;

    struct CoreActionSend {
           comp @0 :Text;
           port @1 :Text;
           selection @2 :Text;
    }
  '';
}
