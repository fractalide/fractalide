{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    @0x95d1db14d7b85555;

    struct CoreGraphImsg {
           imsg @0 :Text;
           comp @1 :Text;
           port @2 :Text;
           selection @3 :Text;
    }

  '';
}
