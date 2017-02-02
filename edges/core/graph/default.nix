{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [
        core_graph_list_edge
        core_graph_list_ext
        core_graph_list_imsg
        core_graph_list_node
      ];
  schema = with edges; ''
    struct CoreGraph {
      path @0 :Text;
      nodes @1 :CoreGraphListNode;
      edges @2 :CoreGraphListEdge;
      imsgs @3 :CoreGraphListImsg;
      externalInputs @4 :CoreGraphListExt;
      externalOutputs @5 :CoreGraphListExt;
    }

  '';
}
