{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    @0xf2f767a9f51e6095;

    struct CoreGraphNode {
           name @0 :Text;
           sort @1 :Text;
    }

  '';
}
