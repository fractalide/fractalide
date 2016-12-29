{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [
        prim_text
        core_graph_list_edge
        core_graph_list_ext
        core_graph_list_imsg
        core_graph_list_node
      ];
  schema = with edges; ''
    @0x819d7d5061be5d17;

    using CoreGraphListEdge = import "${core_graph_list_edge}/src/edge.capnp";
    using CoreGraphListExt = import "${core_graph_list_ext}/src/edge.capnp";
    using CoreGraphListImsg = import "${core_graph_list_imsg}/src/edge.capnp";
    using CoreGraphListNode = import "${core_graph_list_node}/src/edge.capnp";

    struct CoreGraph {
      path @0 :Text;
      nodes @1 :CoreGraphListNode.CoreGraphListNode;
      edges @2 :CoreGraphListEdge.CoreGraphListEdge;
      imsgs @3 :CoreGraphListImsg.CoreGraphListImsg;
      externalInputs @4 :CoreGraphListExt.CoreGraphListExt;
      externalOutputs @5 :CoreGraphListExt.CoreGraphListExt;
    }

  '';
}
