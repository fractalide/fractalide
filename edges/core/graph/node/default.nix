{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ ];
  schema = with edges; ''
    struct CoreGraphNode {
           name @0 :Text;
           sort @1 :Text;
    }

  '';
}
