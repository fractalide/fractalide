{ edge, edges }:

edge.capnp {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct CoreGraphNode {
           name @0 :Text;
           sort @1 :Text;
    }

  '';
}
