{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0x84c8e268d3236b4f;

    struct FbpGraph {
      path @0 :Text;
      nodes @1 :List(Node);
      edges @2 :List(Edge);
      imsgs @3 :List(Imsg);
      externalInputs @4 :List(Ext);
      externalOutputs @5 :List(Ext);
    }

    struct Node {
           name @0 :Text;
           sort @1 :Text;
    }

    struct Edge {
           oName @0 :Text;
           oPort @1 :Text;
           oSelection @2 :Text;
           iName @3 :Text;
           iPort @4 :Text;
           iSelection @5 :Text;
    }

    struct Imsg {
           imsg @0 :Text;
           comp @1 :Text;
           port @2 :Text;
           selection @3 :Text;
    }

    struct Ext {
           name @0 :Text;
           comp @1 :Text;
           port @2 :Text;
           selection @3 :Text;
    }
  '';
}
