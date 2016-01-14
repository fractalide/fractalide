@0x84c8e268d3236b4f;

struct Graph {
  nodes @0 :List(Node);
  edges @1 :List(Edge);
  iips @2 :List(Iip);
  externalInputs @3 :List(Ext);
  externalOutputs @4 :List(Ext);
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