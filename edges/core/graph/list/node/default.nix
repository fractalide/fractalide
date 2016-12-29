{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [ core_graph_node ];
  schema = with edges; ''
    @0xb2c1bf89e3b4778d;

    using CoreGraphNode = import "${core_graph_node}/src/edge.capnp";

    struct CoreGraphListNode {
      list @0 : List(CoreGraphNode.CoreGraphNode);
    }
  '';
}
