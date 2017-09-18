{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ CoreGraphEdge ];
  schema = with edges.capnp; ''
    struct CoreGraphListEdge {
      list @0 : List(CoreGraphEdge);
    }
  '';
}
