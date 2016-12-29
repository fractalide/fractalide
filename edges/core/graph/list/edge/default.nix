{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ core_graph_edge ];
  schema = with edges; ''
    @0x83ec5ff4a1d169af;

    using CoreGraphEdge = import "${core_graph_edge}/src/edge.capnp";

    struct CoreGraphListEdge {
      list @0 : List(CoreGraphEdge.CoreGraphEdge);
    }
  '';
}
