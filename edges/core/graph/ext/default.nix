{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    @0x81458f10b34067d8;

    struct CoreGraphExt {
           name @0 :Text;
           comp @1 :Text;
           port @2 :Text;
           selection @3 :Text;
    }
  '';
}
