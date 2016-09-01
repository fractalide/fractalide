{stdenv, buildFractalideContract, upkeepers, ...}:

buildFractalideContract rec {
  src = ./.;
  contract = ''
  @0x84c8e268d3236b4f;

  struct FbpGraph {
    path @0 :Text;
    nodes @1 :List(Node);
    edges @2 :List(Edge);
    iips @3 :List(Iip);
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

  struct Iip {
         iip @0 :Text;
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

  meta = with stdenv.lib; {
    description = "Contract: Describes the Flow-based graph";
    homepage = https://github.com/fractalide/fractalide/tree/master/contracts/fbp/graph;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
