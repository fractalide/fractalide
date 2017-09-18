{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges.capnp; [ ];
  schema = with edges.capnp; ''
    struct CoreGraphEdge {
           oName @0 :Text;
           oPort @1 :Text;
           oSelection @2 :Text;
           iName @3 :Text;
           iPort @4 :Text;
           iSelection @5 :Text;
    }
  '';
}
